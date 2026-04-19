#!/usr/bin/env bash
# Symlinks dotfiles/<pkg>/ into $HOME via GNU stow, then installs editor
# extensions from extensions.txt manifests.
source "$(dirname "$0")/_lib.sh"

log "stow dotfiles"

have stow || die "stow not found; run install/02-brew-bundle.sh first"

cd "$REPO_ROOT/dotfiles"

PACKAGES=(
  zsh
  git
  bat
  lsd
  starship
  ghostty
  tmux
  ipython
  espanso
  bin
  cursor
  vscode
)

for pkg in "${PACKAGES[@]}"; do
  if [[ ! -d "$pkg" ]]; then
    warn "skipping missing package: $pkg"
    continue
  fi
  info "stow $pkg -> \$HOME"
  if dry_run; then
    stow -nv -t "$HOME" "$pkg" 2>&1 | sed 's/^/    /' || true
  else
    stow --restow --target="$HOME" --adopt "$pkg"
  fi
done

# --- Editor extensions ------------------------------------------------------
install_extensions() {
  local cli="$1" manifest="$2"
  [[ -f "$manifest" ]] || return 0
  if ! have "$cli"; then
    warn "$cli not on PATH; skipping $manifest"
    return 0
  fi
  log "$cli extensions ($(grep -cv '^\s*\(#\|$\)' "$manifest") entries)"
  while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" =~ ^[[:space:]]*# ]] && continue
    if dry_run; then
      info "[dry-run] $cli --install-extension $ext"
    else
      "$cli" --install-extension "$ext" --force >/dev/null 2>&1 \
        && info "  installed $ext" \
        || warn "  failed   $ext"
    fi
  done < "$manifest"
}

install_extensions cursor "$REPO_ROOT/dotfiles/cursor/extensions.txt"
install_extensions code   "$REPO_ROOT/dotfiles/vscode/extensions.txt"
