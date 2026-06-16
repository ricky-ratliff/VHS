#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Refuse to run as root; this is a user-session kiosk installer.
# -----------------------------------------------------------------------------

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "Run this script as the regular user, not root." >&2
  exit 1
fi

# -----------------------------------------------------------------------------
# Small helper to prompt for text input with an optional default.
# ------------------------------------------------------------------------------

prompt() {
  local __var="$1" __msg="$2" __default="${3:-}" __val=""
  if [[ -n "$__default" ]]; then
    read -r -p "$__msg [$__default]: " __val
    __val="${__val:-$__default}"
  else
    read -r -p "$__msg: " __val
  fi
  printf -v "$__var" '%s' "$__val"
}

# -----------------------------------------------------------------------------
# Helper to ask yes/no questions.
# -----------------------------------------------------------------------------

yesno() {
  local __msg="$1" __default="${2:-Y}" __ans=""
  read -r -p "$__msg [${__default}/n]: " __ans
  __ans="${__ans:-$__default}"
  [[ "$__ans" =~ ^[Yy]$ ]]
}

# -----------------------------------------------------------------------------
# Normalize TV hostname to TV-XX format.
# -----------------------------------------------------------------------------

sanitize_tv() {
  local v="$1"
  v="${v^^}"
  v="${v// /-}"
  v="${v//_/-}"
  v="$(printf '%s' "$v" | tr -cd 'A-Z0-9-')"
  echo "$v"
}

# -----------------------------------------------------------------------------
# Ask for the TV hostname and validate it.
# -----------------------------------------------------------------------------

prompt TV_HOSTNAME "Enter TV hostname (example: TV-02)"
TV_HOSTNAME="$(sanitize_tv "$TV_HOSTNAME")"
if [[ ! "$TV_HOSTNAME" =~ ^TV-[0-9]{2}$ ]]; then
  echo "Hostname must match TV-XX, e.g. TV-02" >&2
  exit 1
fi

# -----------------------------------------------------------------------------
# Define all per-TV paths and per-user config locations.
# -----------------------------------------------------------------------------

BASE_DIR="$HOME/Dropbox/VHS"
TV_DIR="$BASE_DIR/$TV_HOSTNAME"
NOW_DIR="$TV_DIR/Now-Playing"
MEDIA_DIR="$NOW_DIR/media"
BIN_DIR="$HOME/bin/$TV_HOSTNAME"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
MPV_CONF_DIR="$HOME/.config/mpv"
UNIT_PREFIX="$(echo "$TV_HOSTNAME" | tr '[:upper:]' '[:lower:]')"

# -----------------------------------------------------------------------------
# Verify the TV-specific Dropbox folder exists before proceeding.
# -----------------------------------------------------------------------------

if [[ ! -d "$TV_DIR" ]]; then
  echo "Dropbox TV folder does not exist yet:"
  echo "  $TV_DIR"
  echo
  echo "Create or sync that folder first, then rerun this script."
  exit 1
fi

# --------------------------------------------------------------------------------------
# Create local working directories for scripts and configuration.
# --------------------------------------------------------------------------------------

mkdir -p "$MEDIA_DIR" "$BIN_DIR" "$SYSTEMD_USER_DIR" "$MPV_CONF_DIR"

# --------------------------------------------------------------------------------------
# Optionally write a minimal mpv.conf if the user wants to.
# --------------------------------------------------------------------------------------

if yesno "Write a minimal mpv.conf now?" "Y"; then
  cat > "$MPV_CONF_DIR/mpv.conf" <<'EOF'
fullscreen=yes
loop-playlist=inf
no-osd-bar
vo=gpu-next
gpu-context=wayland
hwdec=vaapi
EOF
fi

# --------------------------------------------------------------------------------------
# Build script: generate playlist.m3u from the TV's media folder.
# --------------------------------------------------------------------------------------

cat > "$BIN_DIR/build-playlist.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
WATCH_DIR="\$HOME/Dropbox/VHS/$TV_HOSTNAME/Now-Playing/media"
PLAYLIST="\$HOME/Dropbox/VHS/$TV_HOSTNAME/Now-Playing/playlist.m3u"
tmp="\${PLAYLIST}.tmp"
{
  echo "#EXTM3U"
  find "\$WATCH_DIR" -maxdepth 1 -type f \\( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.webm' \\) | sort
} > "\$tmp"
mv "\$tmp" "\$PLAYLIST"
EOF
chmod +x "$BIN_DIR/build-playlist.sh"

# --------------------------------------------------------------------------------------
# Reload script: send the "loadfile" command to mpv's IPC socket to reload the playlist.
# --------------------------------------------------------------------------------------

cat > "$BIN_DIR/reload-mpv.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
SOCK="/tmp/${TV_HOSTNAME}-mpv.sock"
PLAYLIST="\$HOME/Dropbox/VHS/$TV_HOSTNAME/Now-Playing/playlist.m3u"
for i in \$(seq 1 40); do
  [[ -S "\$SOCK" ]] && break
  sleep 0.25
done
if [[ -S "\$SOCK" ]]; then
  printf '{"command":["loadfile","%s","replace"]}\n' "\$PLAYLIST" | socat - "\$SOCK" || true
fi
EOF
chmod +x "$BIN_DIR/reload-mpv.sh"

# --------------------------------------------------------------------------------------
# Watch script: use inotifywait to watch for changes in the media folder and trigger rebuilds.
# --------------------------------------------------------------------------------------

cat > "$BIN_DIR/watch-playlist.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
WATCH_DIR="\$HOME/Dropbox/VHS/$TV_HOSTNAME/Now-Playing/media"
BUILD="\$HOME/bin/$TV_HOSTNAME/build-playlist.sh"
RELOAD="\$HOME/bin/$TV_HOSTNAME/reload-mpv.sh"

"\$BUILD"
"\$RELOAD"

inotifywait -m -e create -e delete -e moved_to -e moved_from -e close_write "\$WATCH_DIR" |
while read -r _; do
  sleep 1
  "\$BUILD"
  "\$RELOAD"
done
EOF
chmod +x "$BIN_DIR/watch-playlist.sh"

# --------------------------------------------------------------------------------------
# MPV kiosk script: launch mpv in fullscreen kiosk mode with the playlist and IPC socket.
# --------------------------------------------------------------------------------------

cat > "$BIN_DIR/mpv-kiosk.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec mpv \
  --fullscreen \
  --loop-playlist=inf \
  --idle=yes \
  --force-window=yes \
  --vo=gpu-next \
  --gpu-context=wayland \
  --hwdec=vaapi \
  --input-ipc-server="/tmp/${TV_HOSTNAME}-mpv.sock" \
  "\$HOME/Dropbox/VHS/$TV_HOSTNAME/Now-Playing/playlist.m3u"
EOF
chmod +x "$BIN_DIR/mpv-kiosk.sh"

# --------------------------------------------------------------------------------------
# Systemd services: one for the playlist watcher, one for the mpv kiosk player.
# --------------------------------------------------------------------------------------

cat > "$SYSTEMD_USER_DIR/${UNIT_PREFIX}-watch-playlist.service" <<EOF
[Unit]
Description=$TV_HOSTNAME Dropbox playlist watcher
After=default.target

[Service]
Type=simple
ExecStart=%h/bin/$TV_HOSTNAME/watch-playlist.sh
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
EOF

cat > "$SYSTEMD_USER_DIR/${UNIT_PREFIX}-mpv-kiosk.service" <<EOF
[Unit]
Description=$TV_HOSTNAME MPV kiosk player
After=graphical-session.target plasma-workspace.target
Wants=graphical-session.target plasma-workspace.target
PartOf=graphical-session.target
Requires=${UNIT_PREFIX}-watch-playlist.service

[Service]
Type=simple
ExecStartPre=/usr/bin/test -f %h/Dropbox/VHS/$TV_HOSTNAME/Now-Playing/playlist.m3u
ExecStart=%h/bin/$TV_HOSTNAME/mpv-kiosk.sh
Restart=always
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF

# Reload systemd user units and enable the services to start on login.

systemctl --user daemon-reload
systemctl --user enable --now "${UNIT_PREFIX}-watch-playlist.service"
systemctl --user enable --now "${UNIT_PREFIX}-mpv-kiosk.service"

# -----------------------------------------------------------------------------
# Done! Print summary of what was set up.
# -----------------------------------------------------------------------------

echo
echo "Done. ✓"
echo "TV host: → $TV_HOSTNAME"
echo "Dropbox TV folder: → $TV_DIR"
echo "Media folder: → $MEDIA_DIR"
echo "Playlist: ▹ $NOW_DIR/playlist.m3u"
echo "Services: ⟳"
echo "  ${UNIT_PREFIX}-watch-playlist.service"
echo "  ${UNIT_PREFIX}-mpv-kiosk.service"