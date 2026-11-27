#!/usr/bin/env bash
# macOS bootstrap: iTerm2 + zsh + starship + atuin + apps, all config symlinked from this repo.
#
#   ./bootstrap.sh            install everything, link dotfiles, configure iTerm
#   ./bootstrap.sh --no-brew  skip installs (relink + configure only)
#   ./bootstrap.sh --dry-run  print what would happen, change nothing
#
# Safe to re-run. Existing files that would be replaced are moved to
# ~/.dotfiles-backup/<timestamp>/ first. Nothing personal is stored in this repo:
# your identity and employer setup live in ~/.gitconfig.local, ~/.zshrc.local, ~/.workrc.
#
# Note: quit iTerm2 before running if you can; otherwise restart it afterwards.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PKGS=(zsh git starship atuin bat iterm bin ipython zed)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
PROFILES_JSON="$REPO/dotfiles/iterm/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"

DRY=0; BREW=1
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --no-brew) BREW=0 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
run()  { if (( DRY )); then printf '    [dry] %s\n' "$*"; else "$@"; fi; }
interactive() { [[ -t 0 && -t 1 ]] && (( ! DRY )); }
# Non-comment, non-blank lines of a list file (never fails, even if the file is all comments).
list_lines() { [[ -f $1 ]] && grep -vE '^[[:space:]]*(#|$)' "$1" || true; }

# --- 1. Xcode CLT + Homebrew --------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (re-run this script when it finishes)"
  run xcode-select --install; exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x $b ]] && eval "$($b shellenv)"; done
fi
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  (( DRY )) || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x $b ]] && eval "$($b shellenv)"; done
fi

# --- 2. Packages ----------------------------------------------------------------
# Apps you already have in /Applications (installed by hand, or by your company's IT)
# are skipped instead of reinstalled, so brew bundle doesn't fail or overwrite them.
filtered_brewfile() {  # $1 = Brewfile; prints it minus casks whose app already exists
  local file="$1" cask apps a skip line
  local installed; installed=" $(brew list --cask 2>/dev/null | tr '\n' ' ') "
  while IFS= read -r line; do
    if [[ $line =~ ^cask\ \"([^\"]+)\" ]]; then
      cask="${BASH_REMATCH[1]}"; skip=0
      if [[ $installed != *" ${cask##*/} "* ]]; then
        apps="$(brew info --json=v2 --cask "$cask" 2>/dev/null | jq -r '.casks[0] |
          ([.artifacts | .. | strings | select(test("^/Applications/[^/]+\\.app$"))]
           + [.artifacts[] | .app? // empty | .[]? | strings | "/Applications/" + .]
           + ["/Applications/" + .name[0] + ".app"]) | unique[]' 2>/dev/null || true)"
        while IFS= read -r a; do [[ -n $a && -d $a ]] && skip=1; done <<<"$apps"
      fi
      if (( skip )); then echo "    skip $cask (already in /Applications)" >&2; continue; fi
    fi
    printf '%s\n' "$line"
  done < "$file"
}

if (( BREW )); then
  # jq is needed to read cask metadata (and by the theme command); install it first.
  command -v jq >/dev/null 2>&1 || run brew install jq

  # Homebrew ignores formulae/casks from non-official taps until they're trusted.
  # Trust exactly the ones the Brewfiles name (user/tap/name), nothing else from those taps.
  for bf in "$REPO/Brewfile" "$REPO/Brewfile.local"; do
    [[ -f $bf ]] || continue
    { grep -oE '^(brew|cask) "[^"/]+/[^"/]+/[^"]+"' "$bf" || true; } | while read -r kind name; do
      name="${name//\"/}"; tap="${name%/*}"
      [[ $tap == homebrew/* ]] && continue
      run brew tap "$tap" 2>/dev/null || true
      if [[ $kind == cask ]]; then run brew trust --quiet --cask "$name" || true
      else run brew trust --quiet --formula "$name" || true; fi
    done
  done

  for bf in "$REPO/Brewfile" "$REPO/Brewfile.local"; do
    [[ -f $bf ]] || continue
    log "brew bundle (${bf##*/})"
    tmp="$(mktemp)"; filtered_brewfile "$bf" > "$tmp"
    # --no-upgrade: installing is this script's job; upgrades are `brew upgrade`'s.
    # One failing package shouldn't stop the rest of the setup.
    run brew bundle --no-upgrade --file="$tmp" || warn "brew bundle (${bf##*/}) had failures; see above, then re-run"
    rm -f "$tmp"
  done
  # zsh's compinit refuses group-writable completion dirs (zsh-completions caveat).
  run chmod go-w "$(brew --prefix)/share"
  [[ -d "$(brew --prefix)/share/zsh" ]] && run chmod -R go-w "$(brew --prefix)/share/zsh"
  if [[ ! -d /Applications/iTerm.app ]]; then
    log "Installing iTerm2"
    run brew install --cask iterm2 || warn "iTerm2 install failed"
  fi
fi

# --- 3. Language toolchains ---------------------------------------------------------
# sdkman.txt lines: <candidate> <version> [default]
#   version can be exact (17.0.21.0+9-tem, 9.9.1) or "<major>-<vendor>" (17-tem): the newest
#   available build of that major is installed, and an already-installed one is reused.
sdk_platform() { [[ $(uname -m) == arm64 ]] && echo darwinarm64 || echo darwinx64; }
sdk_resolve() {  # $1 candidate, $2 version spec -> exact version identifier
  local cand=$1 spec=$2 major vendor have
  if [[ $spec =~ ^([0-9]+)-([a-z]+)$ ]]; then
    major=${BASH_REMATCH[1]}; vendor=${BASH_REMATCH[2]}
    have="$(ls "$HOME/.sdkman/candidates/$cand" 2>/dev/null | grep -E "^${major}\..*-${vendor}$" | sort -V | tail -1 || true)"
    if [[ -n $have ]]; then echo "$have"; return; fi
    curl -fsSL "https://api.sdkman.io/2/candidates/$cand/$(sdk_platform)/versions/list?installed=" 2>/dev/null |
      grep -oE "${major}\.[0-9][0-9.+]*-${vendor}" | sort -V | tail -1 || true
  else
    echo "$spec"
  fi
}
sdk_run() { bash -c 'export sdkman_auto_answer=true; source "$HOME/.sdkman/bin/sdkman-init.sh"; sdk "$@"' _ "$@"; }

if (( BREW )) && [[ -f "$REPO/sdkman.txt" ]]; then
  if [[ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    log "Installing SDKMAN"
    (( DRY )) || curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash || warn "SDKMAN install failed"
  fi
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] || (( DRY )); then
    defaults=()
    # Pass 1: install everything. (Each install makes itself the default, so defaults come after.)
    while read -r cand spec def; do
      ver="$(sdk_resolve "$cand" "$spec")"
      if [[ -z $ver ]]; then warn "sdkman: no $cand version matches '$spec'"; continue; fi
      [[ $def == default ]] && defaults+=("$cand $ver")
      [[ -d "$HOME/.sdkman/candidates/$cand/$ver" ]] && continue
      log "sdk install $cand $ver"
      (( DRY )) || sdk_run install "$cand" "$ver" || warn "sdk install $cand $ver failed"
    done < <(list_lines "$REPO/sdkman.txt")
    # Pass 2: set defaults.
    for d in "${defaults[@]+"${defaults[@]}"}"; do
      read -r cand ver <<<"$d"
      [[ "$(readlink "$HOME/.sdkman/candidates/$cand/current" 2>/dev/null)" == *"$ver" ]] && continue
      log "sdk default $cand $ver"
      (( DRY )) || sdk_run default "$cand" "$ver" >/dev/null || warn "sdk default $cand $ver failed"
    done
  fi
fi

if (( BREW )); then
  # Python CLI tools via uv — listed in uv-tools.txt
  if command -v uv >/dev/null 2>&1; then
    have="$(uv tool list 2>/dev/null | awk '!/^-/{print $1}' || true)"
    while read -r t; do
      grep -qxF "$t" <<<"$have" || { log "uv tool install $t"; run uv tool install "$t" || warn "uv tool install $t failed"; }
    done < <(list_lines "$REPO/uv-tools.txt")
  fi

  # VS Code extensions — listed in dotfiles/vscode/extensions.txt
  code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [[ -x $code_bin ]]; then
    have="$("$code_bin" --list-extensions 2>/dev/null | tr 'A-Z' 'a-z' || true)"
    while read -r e; do
      grep -qxF "$(tr 'A-Z' 'a-z' <<<"$e")" <<<"$have" ||
        { log "VS Code: install $e"; run "$code_bin" --install-extension "$e" >/dev/null || warn "VS Code: $e failed"; }
    done < <(list_lines "$REPO/dotfiles/vscode/extensions.txt")
  fi
fi

# --- 4. Pre-flight: make sure linking will succeed BEFORE moving anything ----------
for tool in stow jq; do
  command -v "$tool" >/dev/null 2>&1 || {
    warn "$tool is required but not installed. Run without --no-brew, or: brew install $tool"; exit 1; }
done

# --- 5. Back up anything stow would collide with ----------------------------------
log "Checking for existing files to back up"
backup_one() {  # $1 = path relative to $HOME
  local tgt="$HOME/$1" real
  [[ -e "$tgt" || -L "$tgt" ]] || return 0
  # Already resolves into this repo (a link, or a file inside a linked folder)? Leave it.
  real="$(realpath "$tgt" 2>/dev/null || true)"
  [[ -n $real && $real == "$REPO"/* ]] && return 0
  echo "    backup ~/$1"
  run mkdir -p "$(dirname "$BACKUP/$1")"
  run mv "$tgt" "$BACKUP/$1"
}
for pkg in "${PKGS[@]}"; do
  while IFS= read -r rel; do backup_one "$rel"; done < <(
    cd "$REPO/dotfiles/$pkg" && find . \( -type f -o -type l \) ! -name '.DS_Store' | sed 's|^\./||')
done

# --- 6. Link dotfiles -----------------------------------------------------------
log "Linking dotfiles into ~ (stow: ${PKGS[*]})"
# --no-folding: link files, never whole directories, so apps can't write into the repo.
# .stow-local-ignore isn't needed: stow ignores .DS_Store etc. by default.
if (( DRY )); then
  stow -n -v --no-folding --restow --dir="$REPO/dotfiles" --target="$HOME" "${PKGS[@]}" 2>&1 |
    grep -vE '^(WARNING|UNLINK|LINK: .* \(reverts previous action\))' | sed 's/^/    [dry] /' || true
else
  stow --no-folding --restow --dir="$REPO/dotfiles" --target="$HOME" "${PKGS[@]}"
fi

# --- 7. Local, never-committed files ------------------------------------------------
if [[ ! -e "$HOME/.zshrc.local" ]]; then
  log "Creating ~/.zshrc.local (machine-specific shell config, not in git)"
  (( DRY )) || cat > "$HOME/.zshrc.local" <<'EOF'
# ~/.zshrc.local — sourced last by ~/.zshrc. NOT tracked in git.
# Machine-specific aliases, paths and secrets go here, e.g.:
#   alias proj='cd ~/code'
#   export SOME_TOKEN=...
EOF
fi

if [[ ! -e "$HOME/.workrc" ]]; then
  log "Creating ~/.workrc (employer-specific shell setup, not in git)"
  (( DRY )) || cat > "$HOME/.workrc" <<'EOF'
# ~/.workrc — sourced by ~/.zshrc. NOT tracked in git.
# Your current employer's shell setup: login helpers, internal CLIs, proxies...
# When you change jobs, replace this file; nothing else needs to change.
EOF
fi

if [[ ! -e "$HOME/.gitconfig.local" ]]; then
  name=""; email=""
  if [[ -f "$BACKUP/.gitconfig" ]]; then
    name="$(git config --file "$BACKUP/.gitconfig" user.name || true)"
    email="$(git config --file "$BACKUP/.gitconfig" user.email || true)"
  fi
  if interactive; then
    [[ -n $name ]]  || read -r -p "    Git name (for commits): " name || name=""
    [[ -n $email ]] || read -r -p "    Git email (for commits): " email || email=""
  fi
  log "Creating ~/.gitconfig.local (your git identity, not in git)"
  if (( ! DRY )); then
    { echo "# ~/.gitconfig.local — your git identity on this machine. NOT tracked in git."
      echo "[user]"
      if [[ -n $name ]];  then echo "	name = $name";   else echo "#	name = Your Name"; fi
      if [[ -n $email ]]; then echo "	email = $email"; else echo "#	email = you@example.com"; fi
    } > "$HOME/.gitconfig.local"
  fi
fi

# --- 8. iTerm2 ------------------------------------------------------------------
if [[ -f "$PROFILES_JSON" ]]; then
  guid="$(jq -r '.Profiles[] | select(.Name=="Dotfiles") | .Guid' "$PROFILES_JSON")"
  log "iTerm2: default profile -> Dotfiles, allow clipboard access"
  run defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$guid"
  # Lets terminal programs (e.g. Claude Code /copy) write to the clipboard via OSC 52.
  run defaults write com.googlecode.iterm2 AllowClipboardAccess -bool true
  # iTerm watches the folder, not the symlink target: touch the link so it reloads the profiles.
  run touch -h "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"
  procs="$(ps -axo comm= 2>/dev/null || true)"   # capture first: grep -q + pipefail = false negatives
  if grep -q '/iTerm.app/Contents/MacOS/iTerm2$' <<<"$procs"; then
    warn "iTerm2 is running: quit it (Cmd-Q) and reopen it so the default profile setting sticks."
  fi
fi

# --- 9. Atuin: import existing zsh history once ---------------------------------
marker="$STATE_DIR/atuin-imported-zsh"
if command -v atuin >/dev/null 2>&1 && [[ ! -e "$marker" && -s "$HOME/.zsh_history" ]]; then
  log "atuin: importing ~/.zsh_history"
  run atuin import zsh && run mkdir -p "$STATE_DIR" && run touch "$marker"
fi

# --- 10. Protect this repo if you publish it --------------------------------------
log "Repo guard: commit hooks (gitleaks + personal deny-list)"
run git -C "$REPO" config core.hooksPath .githooks
noreply_re='^[0-9]+\+[^@]+@users\.noreply\.github\.com$'
if ! [[ "$(git -C "$REPO" config --local user.email || true)" =~ $noreply_re ]]; then
  # Commits to this repo should use your GitHub no-reply address (<id>+<login>@users.noreply.github.com).
  if command -v gh >/dev/null 2>&1 && gh auth status --hostname github.com >/dev/null 2>&1; then
    noreply="$(gh api --hostname github.com user --jq '"\(.id)+\(.login)@users.noreply.github.com"' 2>/dev/null || true)"
    [[ -n $noreply ]] && run git -C "$REPO" config --local user.email "$noreply" && log "Repo commit email -> $noreply"
  else
    warn "Set this repo's commit email to your GitHub no-reply address before committing:"
    warn "  git -C \"$REPO\" config user.email <id>+<login>@users.noreply.github.com"
    warn "  (find it at github.com/settings/emails)"
  fi
fi
denylist="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/forbidden-words"
if [[ ! -e "$denylist" ]]; then
  run mkdir -p "$(dirname "$denylist")"
  (( DRY )) || cat > "$denylist" <<'EOF'
# Words that must never be committed to the dotfiles repo (one per line,
# case-insensitive). This file is NOT in git. Add employer names, internal
# hostnames, project codenames... Your ~/.gitconfig.local email is checked automatically.
EOF
fi

# --- Done -----------------------------------------------------------------------
[[ -d "$BACKUP" ]] && log "Backups saved in $BACKUP"
cat <<'EOF'

Done. Next:
  1. Quit and reopen iTerm2 (Cmd-Q) so it picks up the Dotfiles profile.
  2. Run `theme` to pick a colour theme.
  3. Put employer setup in ~/.workrc and machine-specific bits in ~/.zshrc.local.
EOF
