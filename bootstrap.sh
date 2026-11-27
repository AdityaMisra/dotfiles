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
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGS=(zsh git starship atuin bat iterm bin ipython zed)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
PROFILES_JSON="$REPO/dotfiles/iterm/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"

DRY=0; BREW=1
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --no-brew) BREW=0 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
run()  { if (( DRY )); then printf '    [dry] %s\n' "$*"; else "$@"; fi; }
interactive() { [[ -t 0 && -t 1 ]] && (( ! DRY )); }

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
  local file="$1" cask apps a skip
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
  for bf in "$REPO/Brewfile" "$REPO/Brewfile.local"; do
    [[ -f $bf ]] || continue
    log "brew bundle (${bf##*/})"
    tmp="$(mktemp)"; filtered_brewfile "$bf" > "$tmp"
    run brew bundle --file="$tmp"
    rm -f "$tmp"
  done
  # zsh's compinit refuses group-writable completion dirs (zsh-completions caveat).
  run chmod go-w "$(brew --prefix)/share"
  if [[ ! -d /Applications/iTerm.app ]]; then
    log "Installing iTerm2"
    run brew install --cask iterm2
  fi
fi

# --- 3. Language toolchains ---------------------------------------------------------
if (( BREW )); then
  # SDKMAN (Java, Gradle, ...) — versions listed in sdkman.txt
  if [[ -f "$REPO/sdkman.txt" ]]; then
    if [[ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
      log "Installing SDKMAN"
      (( DRY )) || curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash
    fi
    while read -r cand ver def; do
      [[ -z $cand || $cand == \#* ]] && continue
      if [[ ! -d "$HOME/.sdkman/candidates/$cand/$ver" ]]; then
        log "sdk install $cand $ver"
        (( DRY )) || bash -c 'export sdkman_auto_answer=true; source "$HOME/.sdkman/bin/sdkman-init.sh"; sdk install "$1" "$2"' _ "$cand" "$ver"
      fi
      if [[ $def == default ]] && (( ! DRY )); then
        bash -c 'source "$HOME/.sdkman/bin/sdkman-init.sh"; sdk default "$1" "$2" >/dev/null' _ "$cand" "$ver" || true
      fi
    done < "$REPO/sdkman.txt"
  fi

  # Python CLI tools via uv — listed in uv-tools.txt
  if command -v uv >/dev/null 2>&1 && [[ -f "$REPO/uv-tools.txt" ]]; then
    have="$(uv tool list 2>/dev/null | awk '!/^-/{print $1}')"
    grep -vE '^\s*(#|$)' "$REPO/uv-tools.txt" | while read -r t; do
      grep -qx "$t" <<<"$have" || { log "uv tool install $t"; run uv tool install "$t"; }
    done
  fi

  # VS Code extensions — listed in dotfiles/vscode/extensions.txt
  code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [[ -x $code_bin && -f "$REPO/dotfiles/vscode/extensions.txt" ]]; then
    have="$("$code_bin" --list-extensions 2>/dev/null | tr 'A-Z' 'a-z')"
    grep -vE '^\s*(#|$)' "$REPO/dotfiles/vscode/extensions.txt" | while read -r e; do
      grep -qx "$(tr 'A-Z' 'a-z' <<<"$e")" <<<"$have" || { log "VS Code: install $e"; run "$code_bin" --install-extension "$e" >/dev/null; }
    done
  fi
fi

# --- 4. Back up anything stow would collide with ----------------------------------
log "Checking for existing files to back up"
backup_one() {  # $1 = path relative to $HOME
  local tgt="$HOME/$1"
  [[ -e "$tgt" || -L "$tgt" ]] || return 0
  # Already a link into this repo? fine.
  if [[ -L "$tgt" ]] && [[ "$(cd "$(dirname "$tgt")" && realpath "$(readlink "$tgt")" 2>/dev/null)" == "$REPO"/* ]]; then
    return 0
  fi
  echo "    backup ~/$1"
  run mkdir -p "$(dirname "$BACKUP/$1")"
  run mv "$tgt" "$BACKUP/$1"
}
for pkg in "${PKGS[@]}"; do
  (cd "$REPO/dotfiles/$pkg" && find . \( -type f -o -type l \) ! -name '.DS_Store' | sed 's|^\./||') |
    while IFS= read -r rel; do backup_one "$rel"; done
done

# --- 5. Link dotfiles -----------------------------------------------------------
log "Linking dotfiles into ~ (stow: ${PKGS[*]})"
# --no-folding: link files, never whole directories, so apps can't write into the repo.
run stow --no-folding --restow --dir="$REPO/dotfiles" --target="$HOME" "${PKGS[@]}"

# --- 6. Local, never-committed files ------------------------------------------------
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
    [[ -n $name ]]  || read -r -p "    Git name (for commits): " name
    [[ -n $email ]] || read -r -p "    Git email (for commits): " email
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

# --- 7. iTerm2 ------------------------------------------------------------------
if [[ -f "$PROFILES_JSON" ]]; then
  guid="$(jq -r '.Profiles[] | select(.Name=="Dotfiles") | .Guid' "$PROFILES_JSON")"
  log "iTerm2: default profile -> Dotfiles, allow clipboard access"
  run defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$guid"
  run defaults write com.googlecode.iterm2 AllowClipboardAccess -bool true
  # iTerm watches the folder, not the symlink target: touch the link so it reloads the profiles.
  run touch -h "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"
fi

# --- 8. Atuin: import existing zsh history once ---------------------------------
marker="${ATUIN_HOME:-$HOME/.atuin}/data/.imported-zsh"
if command -v atuin >/dev/null 2>&1 && [[ ! -e "$marker" && -s "$HOME/.zsh_history" ]]; then
  log "atuin: importing ~/.zsh_history"
  run atuin import zsh && run mkdir -p "$(dirname "$marker")" && run touch "$marker"
fi

# --- 9. Protect this repo if you publish it --------------------------------------
log "Repo guard: pre-commit hook (gitleaks + personal deny-list)"
run git -C "$REPO" config core.hooksPath .githooks
if [[ "$(git -C "$REPO" config --local user.email || true)" != *@users.noreply.github.com ]]; then
  # Commits to this repo should use your GitHub no-reply address, not a personal/work email.
  if command -v gh >/dev/null 2>&1 && gh auth status --hostname github.com >/dev/null 2>&1; then
    noreply="$(gh api --hostname github.com user --jq '"\(.id)+\(.login)@users.noreply.github.com"' 2>/dev/null || true)"
    [[ -n $noreply ]] && run git -C "$REPO" config --local user.email "$noreply" && log "Repo commit email -> $noreply"
  else
    warn "Set this repo's commit email to your GitHub no-reply address before committing:"
    warn "  git -C \"$REPO\" config user.email <id>+<user>@users.noreply.github.com"
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
