# TV Client Manual Configurations

Current required manual configurations for VHS TV clients. These could be baked into a base image or added to the vhs-client.sh configuration script in the future.

## Required Packages

The VHS TV Client should have:

- `openssh-server`
- `mpv`
- `inotify-tools`
- `socat`
- `libappindicator3-1`
- `Dropbox` app
- `dropboxd` daemon

Those are the tools the VHS TV client installer and runtime stack depend on.

## TV Client Config Checklist

- [ ] OS Installation Settings
  - [ ] Set a VHS-compliant hostname (i.e. TV-01)
  - [ ] Select "Do not require password to log in"
  - [ ] Select the Minimal installation to conserve limited storage space
  - [ ] Select the option to install available OS updates
- [ ] System Settings
  - [ ] Power Management (disable idle suspend, screen dim/power off)
    - [ ] Power button = sleep
  - [ ] Screen Lock = never
  - [ ] Software Update = manual, never, after rebooting
- [ ] Install baseline packages
  - [ ] Install available firmware updates: `fwupdmgr get-updates`
  - [ ] Install OS updates: `sudo apt update`
  - [ ] `sudo apt install -y openssh-server inotify-tools mpv libappindicator3-1`
  - [ ] run `apt autoremove` to remove unnecessary packages
  - [ ] Delete the `/etc/mpv/mpv.conf` file to simplify mpv to one config file in `~/.config/mpv/mpv.conf`
  - [ ] Dropbox
    - [ ] Desktop app
    - [ ] Daemon
      - [ ] Run `~/.dropbox/dropboxd` and link account
      - [ ] Confirm System Settings > Autostart > Dropbox = running. Restart may be requried.
      - [ ] Preferences > Selective Sync > remove all except current TV client folder > Update
- [ ] Optional
  - [ ] Add installed location Wi-Fi Connection
  - [ ] Tailscale & Tailscale SSH for remote management
