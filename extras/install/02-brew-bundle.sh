#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

log "brew bundle (base Brewfile)"

if ! need brew install/01-homebrew.sh; then
  exit 0
fi

cd "$REPO_ROOT"

if dry_run; then
  info "checking Brewfile against installed packages..."
  brew bundle check --file=Brewfile --verbose 2>&1 | sed 's/^/    /' || true
  exit 0
fi

brew bundle --file=Brewfile
brew bundle cleanup --file=Brewfile --force || true
