# dotfiles

A reproducible macOS setup: **iTerm2 + zsh + Starship + Atuin**, modern CLI tools, editors and apps.
Every config file lives in this repo and is symlinked into `~`, so a new Mac is ready after one command.

Anyone can use it. The repo holds **no personal or employer details**: your name, email and work
setup live in local files that are never committed (see [Your private files](#your-private-files)).

A visual guide to every feature is in [`docs/guide.html`](docs/guide.html). Open it in a browser.

## On a new laptop

1. **Sign in to the basics.** Connect to the internet and sign in to your Apple ID if you want App Store updates.
2. **Get the repo** (anyone can clone it; fork it first if you want to push your own changes):
   ```bash
   git clone https://github.com/AdityaMisra/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```
   On a brand-new Mac, `git` prompts you to install the Xcode Command Line Tools. Accept, then run the clone again.
3. **Preview, then run the bootstrap:**
   ```bash
   ./bootstrap.sh --dry-run   # shows every step, changes nothing
   ./bootstrap.sh             # does it (takes a while the first time)
   ```
   It asks for your git name and email once, and Homebrew may ask for your Mac password.
4. **Restart iTerm2** (Cmd-Q, then reopen it). It now uses the **Dotfiles** profile.
5. **Add your private bits** (optional):
   - `~/.workrc`: your employer's shell setup (login helpers, internal CLIs, proxies).
   - `~/.zshrc.local`: machine-specific aliases, paths and tokens.
   - `~/.config/dotfiles/forbidden-words`: words the commit check must block (employer name, internal hostnames).
6. **Pick a theme:** run `theme`.

Re-run `./bootstrap.sh` at any time; it's safe. To update from GitHub: `./update.sh` (git pull + bootstrap).
Edits to existing files apply immediately (they're symlinks); new files and new packages need the bootstrap run.

### What bootstrap.sh does

| Step | What happens |
| --- | --- |
| 1. Xcode CLT + Homebrew | Installed if missing |
| 2. Packages | `brew bundle --no-upgrade` with `Brewfile` (plus `Brewfile.local` if you create one). **Apps already in `/Applications` are skipped**, not reinstalled. Third-party formulae named in the Brewfiles are marked trusted. A failing package prints a warning instead of stopping the run. iTerm2 is installed if missing. |
| 3. Toolchains | SDKMAN plus the versions in `sdkman.txt` (`17-tem` means the newest Java 17 Temurin), Python CLI tools from `uv-tools.txt`, VS Code extensions from `dotfiles/vscode/extensions.txt` |
| 4. Backup | Checks that `stow` and `jq` are available, then moves existing files that would be replaced to `~/.dotfiles-backup/<timestamp>/` (delete that folder once you're happy) |
| 5. Link | GNU Stow symlinks each `dotfiles/<pkg>/` into `~` (`--no-folding`, so files only, never whole folders) |
| 6. Private files | Creates `~/.gitconfig.local` (asks for your name and email), `~/.zshrc.local` and `~/.workrc` if missing |
| 7. iTerm2 | Sets **Dotfiles** as the default profile, allows clipboard access (lets terminal programs, including ones over SSH, write to your clipboard; needed for Claude Code `/copy`), and reloads the profiles. If iTerm is running, it reminds you to restart it. |
| 8. Atuin | Imports your existing `~/.zsh_history` once |
| 9. Repo guard | Turns on the commit hooks and sets this repo's commit email to your GitHub no-reply address (`<id>+<login>@users.noreply.github.com`, via `gh` if signed in) |

## Your private files

These are created on your machine and **never committed**:

| File | Holds | Loaded by |
| --- | --- | --- |
| `~/.gitconfig.local` | Your git name and email | `~/.gitconfig` (`[include]`) |
| `~/.workrc` | Your employer's shell setup. One generic name, so you just replace it when you change jobs. | `~/.zshrc` |
| `~/.zshrc.local` | Machine-specific aliases, paths, secrets | `~/.zshrc` (last) |
| `Brewfile.local` (in the repo folder, gitignored) | Extra Homebrew packages for this machine only | `bootstrap.sh` |
| `~/.config/dotfiles/forbidden-words` | Words the commit check blocks | `.githooks/pre-commit` |

## Layout

```
bootstrap.sh  update.sh  Brewfile  sdkman.txt  uv-tools.txt
dotfiles/                     # stow packages -> ~
  zsh/      .zshenv .zprofile .zshrc .zsh/{paths,options,history,completions,tools,
                                          aliases,functions,iterm,prompt,plugins}.zsh
  starship/ .config/starship.toml
  atuin/    .config/atuin/config.toml
  git/      .gitconfig .gitignore_global
  iterm/    Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json  (generated)
  zed/      .config/zed/settings.json
  bat/ ipython/ bin/ (gwt, gclean)
  vscode/   extensions.txt (installed by bootstrap)
iterm/
  base.json                   # profile settings: font, keys, cursor, title, alerts, ...
  colors/*.itermcolors        # one theme each
  build-profiles.py           # base.json + colors -> dotfiles.json (and tells iTerm to reload)
docs/guide.html               # visual guide to all features
scripts/                      # gwt (git worktrees), gclean (delete merged branches)
extras/                       # old full-laptop automation (Hammerspoon, launchd, ...) — not installed
```

## iTerm2

The profiles are an iTerm2 [Dynamic Profiles](https://iterm2.com/documentation-dynamic-profiles.html)
file that iTerm reads straight from the repo:

- **Dotfiles** (default): JetBrains Mono Nerd Font 16, unlimited scrollback, mouse reporting, built-in shell integration, notification alerts for escape-sequence messages (used by Claude Code), and new tabs open in the same directory.
- **Keys**: the Natural Text Editing preset. ⌥←/→ jumps by word, ⌘←/→ goes to the start or end of the line, ⌥⌫ and ⌘⌫ delete a word or the whole line. **Right ⌥ is Meta (Esc+)**. Left ⌥ is left alone so that ⌥-combinations like ⌥3 = `#` on UK and many European layouts still work.
- **Cmd-click** a file path (or `path:line`) in any output, like a stack trace or Claude's reply, to open it in **Zed**.
- **Tab title**: the repo name, or `repo ▸ cmd` while something runs (e.g. `dotfiles ▸ claude`).
  To stop Claude Code overwriting it, set `CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1` in the `env` block of `~/.claude/settings.json`.
- **Cursor**: a thin vertical line (`Cursor Type` in `base.json`: 0 = underline, 1 = line, 2 = box).
- **iTerm's Claude Code Workgroup** (Chat / Diff / Code Review peers) is *not* entered automatically, because its Chat session ignores this
  profile. Open it when you want it with **Shell → Workgroups → Claude Code**.
- One child profile per theme. Each inherits everything from Dotfiles and changes only the colours.

**Switching themes:** `theme` (fzf picker), `theme "TokyoNight Storm"`, `theme list`, `theme current`, `theme reset`.
The default (before you pick one) is Catppuccin Mocha.
The change applies to the current tab straight away, and new tabs remember it.
Starship, bat and delta use ANSI colours, so they follow the theme.

**Adding a theme:** download a `.itermcolors` file from
[iTerm2-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes/tree/master/schemes)
into `iterm/colors/`, then run `python3 iterm/build-profiles.py`.
To change profile settings, edit `iterm/base.json` and re-run the script.

## Shell

| Key / command | What it does |
| --- | --- |
| `Ctrl-R` | Atuin full-screen history search. Press Ctrl-R again inside it to cycle the filter: global → host → session → directory → workspace (current git repo) |
| `↑` / `↓` | History entries that start with what you've typed |
| `Tab` | fzf-tab fuzzy completion (with a preview for `cd`) |
| `→` or `Ctrl-Space` | Accept the grey autosuggestion |
| `Ctrl-T` / `Alt-C` (right ⌥) | fzf file picker / cd into a directory |
| `z foo`, `zi` | zoxide: jump to a frequently used directory |
| `Ctrl-X Ctrl-E` | Edit the current command in `$EDITOR` (Zed, then VS Code, then vim) |
| `c`, `cr`, `cn` | `claude`, `claude --resume`, `claude --continue` |
| `gwt add <branch>` | New git worktree in `../<repo>-<branch>`, to run another Claude session on its own branch. `gwt switch`, `gwt rm`, `gwt list`. |
| `gclean` | Delete local branches already merged into the default branch (asks first) |
| `l`, `ll`, `lt` | eza listings (icons, git status, tree) |
| `gs gd gds gl gb` | git status / diff / staged diff / graph log / branches by date |

History is kept in two places: zsh's own `~/.zsh_history` (200k entries, shared between tabs)
and Atuin's SQLite database. Atuin sync is **off**, so history never leaves the machine.
Commands that start with a space aren't recorded, and commands that set a token, secret, password or API key
(`export GITHUB_TOKEN=…`) are kept out of both histories.

Startup time: `zsh-bench` (about 0.25 s).

## Keeping the repo secret-free

If you publish your copy, `bootstrap.sh` has already turned on the hooks in `.githooks/`. They block a commit when:

1. **gitleaks** finds an API key, token, private key or password in the staged changes;
2. the commit email is not your GitHub no-reply address (`<id>+<login>@users.noreply.github.com`);
3. a staged line **or the commit message** contains a word from `~/.config/dotfiles/forbidden-words`, or your `~/.gitconfig.local` email.
   That word list stays **outside** the repo, so add employer names or internal hostnames to it freely.

To scan everything by hand: `gitleaks git .` (history) and `gitleaks dir .` (working tree).

GitHub's own merge commits use your account email, which the hooks can't see. To keep it private, turn on
**GitHub → Settings → Emails → "Keep my email address private"** and **"Block command line pushes that expose my email"**.
