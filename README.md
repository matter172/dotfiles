# dotfiles

Automated Fedora setup scripts. Removes GNOME bloat, updates the system, and installs a lean set of tools and apps — with a clean, checkbox-style progress display.

## Usage

```bash
bash <(curl -fsSL https://github.com/matter172/dotfiles/raw/main/00-setup.sh)
```

That's it. The master script downloads each step and runs them in order, showing progress like this:

```
[1/7] Removing default GNOME software
  [x] Remove libreoffice-core.x86_64
  [x] Remove gnome-tour.x86_64
  ...

[2/7] Updating Fedora
  Checking for updates...
  4 package(s) to update.
  [x] Update coreutils
  [x] Update coreutils-common
  [x] Update kf6-filesystem
  [x] Update wireless-regdb

[3/7] Adding repositories
  [x] Add Proton Pass repository
  [x] Add Terra repository

[4/7] Installing system packages
  [x] Install proton-pass
  [x] Install pipx
  [x] Install zed

[5/7] Installing user apps and Flatpaks
  [x] Install gnome-extensions-cli
  [x] Install Tiling Shell extension
  [x] Install Caffeine extension
  [x] Install Brave Browser
  [x] Install Flatseal
  [x] Install Steam
  [x] Install ProtonPlus
  [x] Install Heroic Games Launcher
  [x] Install Decoder
  [x] Install Packet
  [x] Install Discord
  [x] Install Resources
  [x] Update installed Flatpaks
  [x] Install Gamescope

[6/7] Setting Dash favorites
  [x] Set Dash favorites (7/7 found)

[7/7] Configuring power settings
  [x] Disable auto-sleep on AC
  [x] Disable screen dimming on AC
  [skip] Disable lid-close suspend on AC (key 'lid-close-ac-action' not present on this system)

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
- [Terra](https://terra.fyralabs.com) — used to install Zed as a proper DNF package, so it gets updates through `dnf update` instead of a separate mechanism. Checks `rpm -q terra-release` first and skips re-adding it if already present, since `dnf install --repofrompath` errors on a duplicate repo id rather than being a no-op.

### `04-rooted-add-software.sh`
Installs system packages from the repos added in the previous step:
- `proton-pass`
- `pipx`
- `zed` — from Terra

### `05-non-rooted-add-software.sh`
Installs user-space tools and Flatpaks, one item at a time:
- `gnome-extensions-cli` via pipx
- GNOME extensions, via `gext`: [Tiling Shell](https://github.com/domferr/tilingshell) (window tiling) and [Caffeine](https://extensions.gnome.org/extension/517/caffeine/) (disables screensaver/auto-suspend on demand)
- Flatpaks (pinned to the `flathub` remote explicitly to avoid an interactive remote-choice prompt): Brave, Flatseal, Steam, ProtonPlus, Heroic Games Launcher, Decoder, Packet, Discord, Resources
- Updates all installed Flatpaks (`flatpak update -y --noninteractive`), so previously-installed apps stay current on every run
- **Gamescope** (`org.freedesktop.Platform.VulkanLayer.gamescope`) is installed separately from the main Flatpak loop, since it's a Vulkan layer extension published as multiple refs — one per `org.freedesktop.Platform` runtime branch. Installing it bare is ambiguous in non-interactive mode, so the script detects the installed Platform runtime's branch (via `flatpak list --columns=application,branch`) and installs Gamescope pinned to that exact branch (e.g. `//24.08`).

### `06-non-rooted-update-dash.sh`
Sets the GNOME Dash (Activities overview) favorites/pinned apps, in this order:
Files, Brave, Discord, Steam, Heroic, Zed, Terminal (Ptyxis).

Rather than hardcoding exact `.desktop` filenames (which vary by packaging), it searches the standard application directories (`/usr/share/applications`, Flatpak export dirs, `~/.local/share/applications`) for each app, trying a few known candidate names per app and using the first match. Apps it can't find are skipped (not left as gaps), and a summary like `Set Dash favorites (6/7 found)` is shown. This step runs after the Flatpak installs, since it needs those apps' `.desktop` files to already exist.

### `07-non-rooted-update-power.sh`
Disables auto-sleep, screen dimming, and lid-close suspend — **while on AC power only**. Battery behavior is left untouched. Sets:
- `sleep-inactive-ac-type` → `nothing` (no auto-sleep when inactive on AC)
- `idle-dim` → `false` (no screen dimming on AC)
- `lid-close-ac-action` → `nothing` (closing the lid does nothing on AC — screen stays on, no lock/suspend)

Checks `gsettings list-keys` for each setting before applying it, since some keys (notably `lid-close-ac-action`) aren't present on every GNOME version. Missing keys show as `[skip]` rather than a failure, with the full list of actually-available keys logged for reference.

## Notes

- Scripts prefixed `rooted` require sudo and are run with `sudo bash`.
- Scripts prefixed `non-rooted`/`non-root` run as the current user.
- `bash <(curl ...)` is used at the top level instead of `curl | bash` so any interactive prompts work correctly.
- `00-setup.sh` downloads all scripts to a temp directory, then runs each one in order, passing the shared log file path as an argument.
- The log file lives at `~/.local/state/dotfiles-setup/setup-<timestamp>.log` and is created and `chmod 666`'d before any `sudo` step runs, so both root- and user-owned steps can append to it without permission errors. It is not deleted after the run.
- A cache-busting query string (`?<timestamp>`) is appended to each download URL to avoid stale copies after a push. `00-setup.sh` fetches via `github.com/.../raw/` rather than `raw.githubusercontent.com` directly, since the latter's CDN edge can serve a stale copy for a few minutes after a push even with cache-busting.
- `sudo -v` is called once up front to cache credentials, so you're only prompted for a password once even though several steps each use sudo.
- Flatpak installs use `--noninteractive` and explicitly pin the `flathub` remote, since some app IDs (e.g. Flatseal) exist on multiple remotes and would otherwise prompt to choose one.
- Zed is installed via Terra rather than the official curl installer, so it ships as a proper RPM and stays current through normal Fedora updates.
- All scripts referenced by `00-setup.sh` must end in `.sh` — only `.sh` files are downloaded and run.
