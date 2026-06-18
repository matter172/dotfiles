# dotfiles

Automated Fedora setup scripts. Removes GNOME bloat, updates the system, and installs a lean set of tools and apps.

## Usage

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/matter172/dotfiles/main/00-setup.sh)
```

That's it. The master script fetches and runs each step in order.

## What it does

### `01-rooted-remove-software.sh`
Removes default GNOME apps that aren't needed:
LibreOffice, Firefox, GNOME Tour, Calendar, Boxes, Contacts, Weather, Maps, Clocks, Calculator, Characters, System Monitor, Connections, Font Viewer, simple-scan, yelp, malcontent-control, gnome-abrt, Papers, Showtime, Loupe, Decibels, Mediawriter.

### `02-rooted-update-fedora.sh`
Runs a full system update via `dnf update`.

### `03-rooted-add-software.sh`
Installs via DNF:
- [Proton Pass](https://github.com/matter172/unofficial-proton-pass-rpm) (via unofficial RPM repo)
- `pipx`

### `04-non-rooted-add-software.sh`
Installs user-space tools and Flatpaks:
- [Zed](https://zed.dev) — code editor
- `gnome-extensions-cli` via pipx
- [Tiling Shell](https://github.com/domferr/tilingshell) — GNOME tiling extension
- Flatpaks: Brave, Flatseal, Steam, ProtonPlus, Heroic Games Launcher, Decoder, Packet, Discord

## Notes

- Scripts prefixed `rooted` require sudo and are run with `sudo bash`.
- Scripts prefixed `non-rooted` run as the current user.
- `bash <(curl ...)` is used instead of `curl | bash` so that scripts which read from stdin (e.g. interactive prompts) work correctly.
