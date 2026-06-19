# dotfiles

Automated Fedora setup scripts. Removes GNOME bloat, updates the system, and installs a lean set of tools and apps — with a clean, checkbox-style progress display.

## Usage

```bash
bash <(curl -fsSL https://github.com/matter172/dotfiles/raw/main/00-setup.sh)
```

That's it. The master script downloads each step and runs them in order, showing progress like this:

```
[1/6] Removing default GNOME software
  [x] Remove libreoffice-core.x86_64
  [x] Remove gnome-tour.x86_64
  ...

[2/6] Updating Fedora
  Checking for updates...
  4 package(s) to update.
  [x] Update coreutils
  [x] Update coreutils-common
  [x] Update kf6-filesystem
  [x] Update wireless-regdb

[3/6] Adding repositories
  [x] Add Proton Pass repository
  [x] Add Terra repository

[4/6] Installing system packages
  [x] Install proton-pass
  [x] Install pipx
  [x] Install zed

[5/6] Installing user apps and Flatpaks
  [x] Install gnome-extensions-cli
  [x] Install Tiling Shell extension
  [x] Install Brave Browser
  ...

[6/6] Setting Dash favorites
  [x] Set Dash favorites (7/7 found)

All done.
```

If there's nothing to update in step 2, it prints `Nothing to update.` and skips straight to step 3.

Full command output (dnf, flatpak, curl, etc.) is written to a persistent log file rather than printed to the terminal, so the display stays clean. The log path is printed at the start (and end) of the run if you need to debug a failed item — failures also print their own last few log lines inline, so you usually don't need to open the log file at all.

## What it does

### `lib-checkbox.sh`
Shared helper sourced by every step script. Provides a single `checkbox "label" command...` function that runs a command, prints `[x]`/`[ ]` next to a label, and logs full output. Not run directly.

### `01-rooted-remove-software.sh`
Removes default GNOME apps that aren't needed, one at a time:
LibreOffice, Firefox, GNOME Tour, Calendar, Boxes, Contacts, Weather, Maps, Clocks, Calculator, Characters, System Monitor, Connections, Font Viewer, simple-scan, yelp, malcontent-control, gnome-abrt, Papers, Showtime, Loupe, Decibels, Mediawriter.

### `02-rooted-update-fedora.sh`
Updates Fedora, one package at a time. Runs `dnf check-update` first to get the list of pending packages, then calls `dnf update -y <package>` per package so each shows its own checkbox. If nothing is pending, it prints `Nothing to update.` and exits without any checkboxes.

### `03-rooted-add-repo.sh`
Adds third-party DNF repositories needed by later steps:
- [Proton Pass](https://github.com/matter172/unofficial-proton-pass-rpm) (unofficial RPM repo)
- [Terra](https://terra.fyralabs.com) — used to install Zed as a proper DNF package, so it gets updates through `dnf update` instead of a separate mechanism

### `04-rooted-add-software.sh`
Installs system packages from the repos added in the previous step:
- `proton-pass`
- `pipx`
- `zed` — from Terra

### `05-non-rooted-add-software.sh`
Installs user-space tools and Flatpaks, one item at a time:
- `gnome-extensions-cli` via pipx
- [Tiling Shell](https://github.com/domferr/tilingshell) — GNOME tiling extension
- Flatpaks (pinned to the `flathub` remote explicitly to avoid an interactive remote-choice prompt): Brave, Flatseal, Steam, ProtonPlus, Heroic Games Launcher, Decoder, Packet, Discord

### `06-non-rooted-update-dash.sh`
Sets the GNOME Dash (Activities overview) favorites/pinned apps, in this order:
Files, Brave, Discord, Steam, Heroic, Zed, Terminal.

Rather than hardcoding exact `.desktop` filenames (which vary by packaging), it searches the standard application directories (`/usr/share/applications`, Flatpak export dirs, `~/.local/share/applications`) for each app, trying a few known candidate names per app and using the first match. Apps it can't find are skipped (not left as gaps), and a summary like `Set Dash favorites (6/7 found)` is shown. This step runs last, after the Flatpak installs, since it needs those apps' `.desktop` files to already exist.

## Notes

- Scripts prefixed `rooted` require sudo and are run with `sudo bash`.
- Scripts prefixed `non-rooted` run as the current user.
- `bash <(curl ...)` is used at the top level instead of `curl | bash` so any interactive prompts work correctly.
- `00-setup.sh` downloads all scripts to a temp directory, then runs each one in order, passing the shared log file path as an argument.
- The log file lives at `~/.local/state/dotfiles-setup/setup-<timestamp>.log` and is created and `chmod 666`'d before any `sudo` step runs, so both root- and user-owned steps can append to it without permission errors. It is not deleted after the run.
- A cache-busting query string (`?<timestamp>`) is appended to each download URL to avoid stale copies after a push. `00-setup.sh` fetches via `github.com/.../raw/` rather than `raw.githubusercontent.com` directly, since the latter's CDN edge can serve a stale copy for a few minutes after a push even with cache-busting.
- `sudo -v` is called once up front to cache credentials, so you're only prompted for a password once even though several steps each use sudo.
- Flatpak installs use `--noninteractive` and explicitly pin the `flathub` remote, since some app IDs (e.g. Flatseal) exist on multiple remotes and would otherwise prompt to choose one.
- Zed is installed via Terra rather than the official curl installer, so it ships as a proper RPM and stays current through normal Fedora updates.
