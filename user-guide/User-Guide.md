# VHS - Backline User Guide

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

Contents

- [VHS - Backline User Guide](#vhs---backline-user-guide)
  - [About Video Hosting System (VHS)](#about-video-hosting-system-vhs)
  - [How to Use VHS](#how-to-use-vhs)
    - [Video \& Playlist Management](#video--playlist-management)
    - [VHS Dropbox Folder Layout](#vhs-dropbox-folder-layout)
  - [Backline VHS TV Client Hardware](#backline-vhs-tv-client-hardware)
    - [Sleep Mode](#sleep-mode)
    - [Acer CXI2 Supported Video Quality](#acer-cxi2-supported-video-quality)
    - [Specs](#specs)

<div class="page"/>

## About Video Hosting System (VHS)

VHS is a free open source digital signage service that configures a Linux-based client to boot straight into looping video(s) in fullscreen with minimal desktop overhead.

Each TV client deployed with VHS is treated as **a complete VHS instance** with its own Dropbox `media` subfolder. VHS provides the playlist builder, file watcher, and media player kiosk services, while keeping the user workflow consistent across all clients. Users only need to place their content into a TV client's Dropbox folder `(e.g. TV-XX/Now-Playing/media/video.mp4)` to automatically update the playlist for that TV.

## How to Use VHS

### Video & Playlist Management

1. Log in to Dropbox, then add the video(s) that you want to have playing on a TV into the `/Now-Playing/media` folder for that TV.
   1. **For Example:** If I want to add or remove a video from the playlist for TV-01, I would make my changes in `VHS/TV-01/Now-Playing/media/`.
2. The TV playlist `(Now-Playing/playlist.m3u)` updates automatically when the `media` folder contents change.
   1. :warning: Manually editing the `playlist.m3u` files can break the VHS services.
3. Use the Archive folder `(VHS/Archive/)` to store "inactive" videos (not currently being played on any TV), that you want to keep around for easy access in the future.

### VHS Dropbox Folder Layout

```text
~/Dropbox/
  └── VHS/
      ├── Archive(always excluded from sync)/
      ├── TV-01/
      │   └── Now-Playing/
      │       ├── media/
      │       │   ├── video1.mp4
      │       │   ├── video2.mp4
      │       │   └── ...
      │       └── playlist.m3u   
      ├── TV-02/
      │   └── Now-Playing/
      │       ├── media/
      │       │   ├── video3.mov
      │       │   ├── video4.mkv
      │       │   └── ...
      │       └── playlist.m3u   
```

- The `VHS` folder is the root Dropbox folder `(Dropbox/VHS/)`.
- The Archive folder `(/Dropbox/VHS/Archive)` stores all inactive videos and *is excluded from sync on all TV clients*. Files placed here will not be played on any TV.
- Each TV has it's own `media` folder `(TV-XX/Now-Playing/media/)` where the active content for that TV is stored, along with the corresponding playlist `(Now-Playing/playlist.m3u)` file that automatically updates when the media folder contents are changed.

> Dropbox allows syncing up to 3 devices for free. Adding a fourth VHS TV client will require a subscription.

## Backline VHS TV Client Hardware

### Sleep Mode

:bulb: Your Chromeboxes are configured to "sleep" when the power button is pressed. To easily turn a VHS TV client on or off:

- A single, short press of the power button will put the box into sleep mode.
- A single, short press of the power button will wake the box to resume video playback.
- Holding down the power button will force a full shut down.

### Acer CXI2 Supported Video Quality

1080p/H.264 is the safest target for reliable signage playback on this Chromebox. On a Broadwell GPU using the i965 VA-API driver, supported decode profiles include MPEG-2, H.264 (Baseline/Main/High), VC-1, JPEG, and VP8.

For reliable playback, use or re-encode video files to:

- 1080p (or lower)
- H.264
- Moderate bitrate
- Constant frame rate

This will provide a much better chance of zero-stutter looping on this hardware.

### Specs

- Make/Model: Acer Chromebox CXI2
- Processor: Intel Celeron 3205U 1.5 GHz
- GPU: Intel HD Graphics (Broadwell GT1)
- RAM: 4 GB DDR3L SDRAM
- Storage: 16 GB (6 GB used, 6 GB avail. post-install)
- Video: HDMI, DisplayPort
- Networking: Ethernet, WiFi (802.11 AC)
  - Using Backline Wi-Fi

---

🄯 Ricky

AGPL-3.0

view full source code & license:
