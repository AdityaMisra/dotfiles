#!/usr/bin/env bash
# Symlinks ~/.hammerspoon to $REPO_ROOT/hammerspoon so Hammerspoon picks up
# the repo-tracked init.lua and modules.
source "$(dirname "$0")/_lib.sh"

log "Hammerspoon config"

TARGET="$HOME/.hammerspoon"
SOURCE="$REPO_ROOT/hammerspoon"

[[ -d "$SOURCE" ]] || die "missing $SOURCE"

if [[ -L "$TARGET" ]]; then
  current="$(readlink "$TARGET")"
  if [[ "$current" == "$SOURCE" ]]; then
    info "already linked: $TARGET -> $SOURCE"
    exit 0
  fi
  warn "$TARGET points elsewhere ($current); replacing"
  run rm "$TARGET"
elif [[ -e "$TARGET" ]]; then
  backup="${TARGET}.bak.$(date +%Y%m%d%H%M%S)"
  warn "$TARGET exists and is not a symlink; backing up to $backup"
  run mv "$TARGET" "$backup"
fi

run ln -s "$SOURCE" "$TARGET"
info "linked $TARGET -> $SOURCE"
info "open Hammerspoon.app once to grant Accessibility permission"
