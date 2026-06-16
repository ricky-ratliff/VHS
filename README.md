# VHS TV Client

```html
           ┌────────────────────────────────────────────────────┐
           │                                                    │
           │`8.`888b           ,8'8 8888        8   d888888o.   │
           │ `8.`888b         ,8' 8 8888        8 .`8888:' `88. │
           │  `8.`888b       ,8'  8 8888        8 8.`8888.   Y8 │
           │   `8.`888b     ,8'   8 8888        8 `8.`8888.     │
           │    `8.`888b   ,8'    8 8888        8  `8.`8888.    │
           │     `8.`888b ,8'     8 8888        8   `8.`8888.   │
           │      `8.`888b8'      8 8888888888888    `8.`8888.  │
           │       `8.`888'       8 8888        88b   `8.`8888. │
           │        `8.`8'        8 8888        8`8b.  ;8.`8888 │
           │         `8.`         8 8888        8 `Y8888P ,88P' │
           └────────────────────────────────────────────────────┘
                           〖VIDEO HOSTING SYSTEM〗
```

VHS (Video Hosting System) is a simple digital signage client installer and runtime setup for Kubuntu 26.04 LTS running KDE Plasma 6.6.4 on Wayland. It uses a locally synced Dropbox folder structure to generate a playlist when the media folder contents change, and loops the playlist in fullscreen automatically through systemd user services without any user intervention on the TV client.

## About This Version

This version is designed to be run after Dropbox is already installed on the client and the [VHS folder structure](./README.md#vhs-dropbox-folder-layout) has already been created in Dropbox. The installer asks for the TV number (TV-XX), verifies the corresponding `~/Dropbox/VHS/TV-XX` exists, then creates the local scripts and systemd user services needed to keep playback running automatically.

## Installation

### TV Client Prerequisites

- Kubuntu 26.04 LTS is already installed.
- KDE Plasma 6.6.4 is the desktop environment.
  - The session is running on Wayland through KWin.
- The [TV Client Manual Configurations](./configs/tv-client-config.md) have been applied.
- The Dropbox desktop app and daemon have already been installed and signed in to manually.
  - The TV Dropbox folder already exists locally at `~/Dropbox/VHS/TV-XX`.
  - All other TV Dropbox folders have been excluded
- The installer is run without root `(sudo)`.

### Installer Script Workflow

1. Run the installer script [vhs-client.sh](./vhs-client.sh) as regular user without sudo:

    ```sh
    user@TV-XX$ ./vhs-client.sh
    ```

2. Enter the TV number, such as `TV-02`.
3. The script verifies that `~/Dropbox/VHS/TV-XX` exists.
4. The script installs dependencies, configures mpv, and creates the VHS helper scripts and systemd user services.
5. The watcher keeps the playlist updated when media files change.
6. MPV Loops the generated playlist in fullscreen.

### What the installer creates

The installer generates the following files for the selected TV:

- `~/bin/TV-XX/build-playlist.sh`
- `~/bin/TV-XX/reload-mpv.sh`
- `~/bin/TV-XX/watch-playlist.sh`
- `~/bin/TV-XX/mpv-kiosk.sh`
- `~/.config/systemd/user/tv-xx-watch-playlist.service`
- `~/.config/systemd/user/tv-xx-mpv-kiosk.service`

The script also enables both services with `systemctl --user enable --now`, so the `systemd --user` units are the authoritative startup mechanism.

## Service model

The playlist watcher is responsible for rebuilding `playlist.m3u` whenever files in `Now-Playing/media` change. The mpv kiosk service depends on the watcher service and starts only when the playlist exists. This keeps the playback flow simple and repeatable.

## Expected behavior

When you add or remove media files in a TV's media folder on Dropbox `Dropbox/VHS/TV-XX/Now-Playing/media`, the watcher on the TV client notices the change, rebuilds `playlist.m3u`, and tells mpv to reload the playlist. mpv stays in fullscreen loop mode and continues playing without manual intervention.

## Troubleshooting

### Video Performance Issues

#### Confirm Media File Codec

To confirm the codec, you can check with a tool like `ffprobe` on the command line. On a Broadwell GPU using the i965 VA-API driver, supported decode profiles include MPEG-2, H.264 (Baseline/Main/High), VC-1, JPEG, and VP8.

#### Check MPV User Service Logs

`journalctl --user -u tv-01-mpv-kiosk.service -b`

#### 10 Most Recent Logs

`journalctl --user -u tv-01-mpv-kiosk.service -b | tail`

### The script says the TV folder does not exist

Make sure Dropbox is already installed, logged in, and syncing the correct VHS folder structure locally before running the script.

#### VHS Dropbox Folder Layout

Each TV client uses its own folder, and the active client reads only its own `TV-XX/Now-Playing` path.

```txt
~/Dropbox/
  └── VHS/
      ├── TV-XX/
      │   └── Now-Playing/
      │       ├── media/
      │       │   ├── video1.mp4
      │       │   ├── video2.mp4
      │       │   └── ...
      │       └── playlist.m3u
      ├── TV-XX/    
      │   └── Now-Playing/
      │       ├── media/
      │       │   ├── video3.mp4
      │       │   ├── video4.mp4
      │       │   └── ...
      │       └── playlist.m3u
```

### The watcher service starts, but mpv does not

Check whether `playlist.m3u` exists and whether the service can access `/tmp/TV-XX-mpv.sock`. Also confirm that `systemctl --user status tv-xx-watch-playlist.service` and `tv-xx-mpv-kiosk.service` are both active.

### Nothing starts after login

Confirm that the services were enabled with `systemctl --user enable --now` and that the user session manager is running normally.
