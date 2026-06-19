# dotfiles

Automated Fedora setup scripts. Removes GNOME bloat, updates the system, and installs a lean set of tools and apps — with a clean, checkbox-style progress display.

## Usage

```bash
bash <(curl -fsSL https://github.com/matter172/dotfiles/raw/main/00-setup.sh)
```

That's it. The master script downloads each step and runs them in order, showing progress like this:

```
[1/5] Removing default GNOME software
  [x] Remove libreoffice-core.x86_64
  [x] Remove gnome-tour.x86_64
  ...

[2/5] Updating Fedora
  [x] Update Fedora packages

[3/5] Adding repositories
  [x] Add Proton Pass repository
  [x] Add Terra repository

[4/5] Installing system packages
  [x] Install proton-pass
  [x] Install pipx
  [x] Install zed

[5/5] Installing user apps and Flatpaks
  [x] Add ~/.local/bin to PATH
  [x] Install gnome-extensions-cli
  [x] Install Tiling Shell extension
  [x] Install Brave Browser
  ...

All done.
```

Full command output (dnf, flatpak, curl, etc.) is written to a persistent log file rather than printed to the terminal, so the display stays clean. The log path is printed at the start (and end) of the run if you need to debug a failed item — failures also print their own last few log lines inline, so you usually don't need to open the log file at all.

## What it does

### `lib-checkbox.sh`
Shared helper sourced by every step script. Provides a single `checkbox "label" command...` function that runs a command, prints `[x]`/`[ ]` next to a label, logs full output, and returns the wrapped command's real exit status (so failures propagate correctly even through nested scripts). Not run directly.

### `01-rooted-remove-software.sh`
Removes default GNOME apps that aren't needed, one at a time:
LibreOffice, Firefox, GNOME Tour, Calendar, Boxes, Contacts, Weather, Maps, Clocks, Calculator, Characters, System Monitor, Connections, Font Viewer, simple-scan, yelp, malcontent-control, gnome-abrt, Papers, Showtime, Loupe, Decibels, Mediawriter.

### `02-rooted-update-fedora.sh`
Runs a full system update via `dnf update`.

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
- `~/.local/bin` added to `PATH` (needed so pipx-installed binaries like `gext` are found)
- `gnome-extensions-cli` via pipx
- [Tiling Shell](https://github.com/domferr/tilingshell) — GNOME tiling extension
- Flatpaks (pinned to the `flathub` remote explicitly to avoid an interactive remote-choice prompt): Brave, Flatseal, Steam, ProtonPlus, Heroic Games Launcher, Decoder, Packet, Discord

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
