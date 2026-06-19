# dotfiles

Automated Fedora setup scripts. Removes GNOME bloat, updates the system, and installs a lean set of tools and apps — with a clean, checkbox-style progress display.

## Usage

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/matter172/dotfiles/refs/heads/main/00-setup.sh)
```

That's it. The master script downloads each step and runs them in order, showing progress like this:

```
[1/4] Removing default GNOME software
  [x] Remove libreoffice-core.x86_64
  [x] Remove gnome-tour.x86_64
  [ ] Remove gnome-maps.x86_64 (failed — see log)
  ...

[2/4] Updating Fedora
  [x] Update Fedora packages

[3/4] Installing system packages
  [x] Add Proton Pass repository
  [x] Install proton-pass
  [x] Install pipx

[4/4] Installing user apps and Flatpaks
  [x] Install Zed editor
  [x] Add ~/.local/bin to PATH
  [x] Install gnome-extensions-cli
  [x] Install Tiling Shell extension
  [x] Install Brave Browser
  ...

All done.
```

Full command output (dnf, flatpak, curl, etc.) is written to a temp log file rather than printed to the terminal, so the display stays clean. The log path is printed at the start of the run if you need to debug a failed item.

## What it does

### `lib-checkbox.sh`
Shared helper sourced by every step script. Provides a single `checkbox "label" command...` function that runs a command, prints `[x]`/`[ ]` next to a label, and logs full output to the shared log file. Not run directly.

### `01-rooted-remove-software.sh`
Removes default GNOME apps that aren't needed, one at a time:
LibreOffice, Firefox, GNOME Tour, Calendar, Boxes, Contacts, Weather, Maps, Clocks, Calculator, Characters, System Monitor, Connections, Font Viewer, simple-scan, yelp, malcontent-control, gnome-abrt, Papers, Showtime, Loupe, Decibels, Mediawriter.

### `02-rooted-update-fedora.sh`
Runs a full system update via `dnf update`.

### `03-rooted-add-software.sh`
Installs via DNF, one item at a time:
- [Proton Pass](https://github.com/matter172/unofficial-proton-pass-rpm) repository (via unofficial RPM repo)
- `proton-pass`
- `pipx`

### `04-non-rooted-add-software.sh`
Installs user-space tools and Flatpaks, one item at a time:
- [Zed](https://zed.dev) — code editor
- `~/.local/bin` added to `PATH`
- `gnome-extensions-cli` via pipx
- [Tiling Shell](https://github.com/domferr/tilingshell) — GNOME tiling extension
- Flatpaks: Brave, Flatseal, Steam, ProtonPlus, Heroic Games Launcher, Decoder, Packet, Discord

## Notes

- Scripts prefixed `rooted` require sudo and are run with `sudo bash`.
- Scripts prefixed `non-rooted` run as the current user.
- `bash <(curl ...)` is used at the top level instead of `curl | bash` so any interactive prompts work correctly.
- `00-setup.sh` downloads all scripts to a temp directory, then runs each one in order, passing the shared log file path as an argument.
- The log file is created and `chmod 666`'d before any `sudo` step runs, so both root- and user-owned steps can append to it without permission errors.
- A cache-busting query string (`?<timestamp>`) is appended to each download URL to avoid stale copies from GitHub's CDN right after a push.
- `sudo -v` is called once up front to cache credentials, so you're only prompted for a password once even though steps 1–3 each use sudo.
