# Dropbox Installation Requirements

This information was copied from the Dropbox website to consolidate all relevant info into one document for convenience.

## Base Requirements

### Supported desktop environments

The Dropbox tray icon needs a desktop environment that supports AppIndicator, which desktop apps use to display icons in the system tray. Not all desktop environments support AppIndicator natively.

The following desktop environments generally support AppIndicator:

- Unity
- KDE Plasma

Determine desktop environment:

```bash
echo $XDG_CURRENT_DESKTOP
```

### Required software libraries

You’ll also need all of the following software libraries to run the app:

- GTK 2.24 or later
- GDK 2.24 or later
- Glib 2.40 or later
- Libappindicator 12.10 or later

### To install LibAppIndicator on Linux

Dropbox uses an external library called LibAppIndicator to interact with AppIndicator. For the full Dropbox experience, you’ll need to install this library:

#### Debian or Ubuntu

Open your Terminal application.
Copy and paste the following command into Terminal, then press Enter:

```bash
sudo apt install libappindicator3-1
```

## Install Dropbox on Linux

When your download is complete, run the Dropbox installer

- Ubuntu 22.10 or higher (.deb) [64-bit Download](https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2026.05.06_amd64.deb)

> The version of this application does not change as frequently as the main Dropbox application. These packages will always install the latest version of Dropbox for Linux.

## The headless Dropbox app

To run the Dropbox app using the command line only, you only need the Dropbox app essential requirements. You can then install the app and use the Linux Command Line Interface (CLI) to control it.

### Dropbox Headless Install via command line

The Dropbox daemon is only compatible with 64-bit Linux servers. To install, run the following command in your Linux terminal.

```bash
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
```

Next, run the Dropbox daemon from the newly created `.dropbox-dist` folder: `~/.dropbox-dist/dropboxd`

> If you’re running Dropbox on your server for the first time, you’ll be asked to copy and paste a link in a working browser to create a new account or add your server to an existing account. Once you do, your Dropbox folder will be created in your home directory. Download this [Python script](https://www.dropbox.com/download?dl=packages/dropbox.py) to control Dropbox from the command line. For easy access, put a symlink to the script anywhere in your PATH.

### Dropbox Linux Commands

The Dropbox **desktop app** can be controlled with the [Linux Command Line Interface (CLI)](https://help.dropbox.com/installs/linux-commands#commands). Before running commands, ensure that you’re running the available commands while your prompt is located at the root (top level) of the Dropbox folder.

By default, the Dropbox folder is located in `~/Dropbox` (or `~/Dropbox (Your team name)`, if you have a Dropbox team account). If you moved the Dropbox folder to a different location, be sure you navigate to the root of your actual Dropbox folder before running the commands.

### How to prepare Dropbox on the golden image

Follow the steps in this article to avoid any unexpected issues when cloning an OS image with Dropbox installed.

Before making an image of the OS, remove the user specific Dropbox files. This forces Dropbox to create unique keys and instance data for each user on the cloned machines.

1. [Download the Dropbox installer](https://help.dropbox.com/installs/download-dropbox) on the golden image.
2. Follow the steps to install Dropbox, but don’t sign in when prompted.
   1. Installer
      1. ~/dropbox_2026.05.06_amd64.deb
3. Click the [Dropbox logo in the menu bar](https://help.dropbox.com/installs/system-tray-menu-bar?fallback=true).
4. Click your avatar (profile photo or initials) in the bottom-left corner.
5. Click **Quit Dropbox**.
6. Delete the “-/.dropbox” hidden folder from your home directory.
    - **Note**: Don’t run Dropbox again before the imaging or snapshot process. This recreates the .dropbox folder.
7. Remove any specific-system identifying information such as the UUID, static IP addresses, etc.  to finalize the installation before cloning.
8. Shut down the workstation and create the golden image.

When a user starts the Dropbox app on a cloned machine, the Dropbox user directory is automatically recreated for that individual user.
