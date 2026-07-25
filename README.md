# dotfiles

- INSTALL `btop`

Portable, idempotent macOS bootstrap. Clone, run `./bootstrap.sh`, get a
working setup. Re-run any time to update; per-machine differences live in
`hosts/<alias>/`.

The legacy (Powerlevel9k / Vundle / hardcoded paths) version is preserved at
the [`v0-legacy`](https://github.com/AdityaMisra/dotfiles/releases/tag/v0-legacy)
tag.

## Prerequisites

- macOS 13+ (Ventura or newer)
- Apple ID signed in to the App Store (only if you use `mas` entries)
- Internet access (Homebrew, npm, pipx, SDKMAN)

That's it. `bootstrap.sh` installs Xcode CLT, Homebrew, and everything else.

## One-line install

```bash
git clone https://github.com/AdityaMisra/dotfiles.git ~/.dotfiles \
  && cd ~/.dotfiles \
  && ./bootstrap.sh
```

Dry run first (no system mutation):

```bash
./bootstrap.sh --dry-run
```

Run a single phase only:

```bash
./bootstrap.sh --only 04   # only stow dotfiles + install editor extensions
```

To pull updates and re-bootstrap:

```bash
~/.dotfiles/update.sh
```

## What lives where

```
~/.dotfiles/
├── bootstrap.sh          # entry point
├── update.sh             # git pull --ff-only && bootstrap.sh
├── Brewfile              # base packages (every machine)
├── install/              # ordered install/[00-99]-*.sh phases
├── dotfiles/             # GNU Stow packages -> ~ symlinks
│   ├── zsh/              # .zshenv, .zshrc, .zsh/{paths,history,...}
│   ├── git/              # .gitconfig, .gitignore_global
│   ├── starship/         # .config/starship.toml (replaces Powerlevel9k)
│   ├── ghostty/          # .config/ghostty/config
│   ├── tmux/             # .tmux.conf
│   ├── cursor/, vscode/  # editor settings + extensions.txt manifests
│   ├── bat/, lsd/, espanso/, ipython/
│   └── bin/              # symlinks scripts/* into ~/.local/bin
├── hammerspoon/          # init.lua + modules (Hyper, tiling, launchers)
├── scripts/              # focus, workspace, meeting, mic, cam, gwt, ...
├── applescript/          # called by scripts/ and Hammerspoon
├── shortcuts/            # exported macOS .shortcut files
├── launchd/              # ~/Library/LaunchAgents plists (cleanup, backup)
└── hosts/                # per-machine overlays
    ├── _map.sh           # LocalHostName -> alias
    ├── work-laptop/      # Brewfile.work, install.sh, zshrc.local
    └── personal/
```

## Module reference

| Path | Purpose |
| --- | --- |
| `install/00-xcode-clt.sh` | Triggers Xcode Command Line Tools install. |
| `install/01-homebrew.sh` | Installs Homebrew if missing. |
| `install/02-brew-bundle.sh` | Applies `Brewfile`. |
| `install/03-macos-defaults.sh` | Dock, Finder, keyboard, screenshots defaults. |
| `install/04-stow-dotfiles.sh` | Stows every `dotfiles/<pkg>/` and installs editor extensions from `extensions.txt`. |
| `install/05-hammerspoon.sh` | Symlinks `~/.hammerspoon` -> `hammerspoon/`. |
| `install/06-shortcuts-import.sh` | Opens `shortcuts/*.shortcut` for one-time import. |
| `install/07-launchd.sh` | Installs + bootstraps launchd plists. |
| `install/08-host-overlay.sh` | Runs `hosts/<alias>/{Brewfile.work,install.sh,zshrc.local}`. |
| `install/99-post.sh` | Prints manual follow-up checklist. |
| `hammerspoon/modules/hyper.lua` | Defines the Hyper modifier (used by other modules). |
| `hammerspoon/modules/tiling.lua` | `hyper+H/J/K/L` halves, `hyper+U/I/N/M` quarters, `hyper+F` full, `hyper+C` center. |
| `hammerspoon/modules/launchers.lua` | `hyper+T` Ghostty, `hyper+B` Chrome, `hyper+E` Cursor, `hyper+S` Slack, `hyper+Z` Zoom. |
| `hammerspoon/modules/mediakeys.lua` | `hyper+M` mic, `hyper+V` camera, `hyper+D` Slack DND, `hyper+J` join meeting. |
| `scripts/focus` | `focus on/off/toggle` -- DND + Slack snooze + Dock autohide. |
| `scripts/workspace` | Opens project from `~/.workspaces.toml`. |
| `scripts/meeting` | Opens link of next Calendar event. |
| `scripts/mic`, `scripts/cam` | Toggle mic/camera in Zoom or Meet. |
| `scripts/gwt` | `gwt add/switch/rm/list` git worktree helper. |
| `scripts/gclean` | Delete local branches merged into `origin/HEAD`. |
| `scripts/clip` | Fuzzy search Maccy clipboard history. |
| `scripts/note` | Append to `~/Notes/inbox.md`. |
| `scripts/cleanup`, `scripts/backup` | Maintenance + rsync backup; wired to launchd. |

## Per-machine overlays (`hosts/`)

`install/08-host-overlay.sh` resolves `LocalHostName` via `hosts/_map.sh` and
runs anything it finds under `hosts/<alias>/`:

- `Brewfile.work` -> `brew bundle`
- `install.sh` -> arbitrary idempotent setup (e.g. SDKMAN + Java + ed25519 keygen)
- `zshrc.local` -> copied to `~/.zshrc.local` (sourced last from `~/.zshrc`)

To add a new machine:

```bash
host=$(scutil --get LocalHostName)
mkdir -p hosts/myalias
# add a case to hosts/_map.sh mapping "$host" -> "myalias"
```

### Keeping employer-internal config out of git

This repo is public, so `hosts/<alias>/` ships only generic / open-source
tools. Anything that would leak internal infrastructure -- Vault URLs,
private package indexes, proprietary CLIs, real LocalHostNames -- belongs
in a sibling directory:

```
hosts/work-laptop/         # public, committed (generic)
hosts/work-laptop.local/   # gitignored, your real internal config
hosts/_map.local.sh        # gitignored, real LocalHostName -> alias mapping
```

`install/08-host-overlay.sh` prefers `hosts/<alias>.local/` when it exists,
so the private overlay always wins. `_map.sh` exec's `_map.local.sh` first
when present. Both `*.local/` and `_map.local.sh` are in `.gitignore`.

Never commit a real internal hostname, internal hostname pattern, or the
name of an internal-only package to `hosts/<alias>/` or `_map.sh`.

## Adding a new automation

- New CLI script: drop it in `scripts/`, `chmod +x`, then symlink into the
  stow package: `ln -s ../../../../scripts/myscript dotfiles/bin/.local/bin/myscript`.
- New AppleScript: put it under `applescript/` and call it via
  `run_applescript "name.applescript"` from a script in `scripts/`.
- New Hammerspoon module: add `hammerspoon/modules/<name>.lua` and
  `require("modules.<name>")` from `hammerspoon/init.lua`.
- New scheduled task: drop a plist in `launchd/` (use `{{HOME}}` and
  `{{REPO_ROOT}}` placeholders); `install/07-launchd.sh` will template + load it.
- New global package: append to `Brewfile`. Per-machine? `hosts/<alias>/Brewfile.work`.

## Troubleshooting

- **Hammerspoon hotkeys don't fire**: open Hammerspoon.app, grant
  Accessibility (System Settings > Privacy & Security > Accessibility).
- **Hyper key isn't producing four-modifier chord**: install Karabiner-Elements
  (cask) and import its complex modification mapping `caps_lock` -> 
  `left_control + left_option + left_command + left_shift`. Without
  Karabiner the Hammerspoon Hyper hotkeys won't trigger from caps lock.
- **`shortcuts run` says "no shortcut found"**: open Shortcuts.app and
  create user-named shortcuts ("Focus On", "Focus Off") that toggle the
  desired Focus mode; `scripts/focus` invokes them by name.
- **Stow conflicts on first run**: `04-stow-dotfiles.sh` uses `--adopt` to
  pull conflicting target files into the repo. Inspect with `git status`
  inside `dotfiles/` before committing -- you may want to discard local
  changes if they were stale.
- **Editor `cursor`/`code` extensions don't install**: open Cursor/VS Code
  once so they install their CLI shim, then re-run
  `./bootstrap.sh --only 04`.
- **Backup script can't read `~/Library`**: grant Full Disk Access to
  `/usr/bin/rsync` (or to your terminal app) under
  System Settings > Privacy & Security > Full Disk Access.

## Rolling back to the legacy setup

```bash
git fetch --tags
git checkout v0-legacy
# manually copy out the configs you want
git checkout master
```

The `v0-legacy` tag will not move; it's an immutable snapshot of the
pre-modernization repo (Powerlevel9k era, Vundle, hardcoded Go 1.15.1 and
`area51/flutter` paths).

## License

[MIT](LICENSE) (matches the repo's existing license).
