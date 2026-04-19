#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

log "brew bundle (base Brewfile)"

have brew || die "brew not found; install/01-homebrew.sh must succeed first"

cd "$REPO_ROOT"

if dry_run; then
  brew bundle check --file=Brewfile --verbose || true
  exit 0
fi

brew bundle --file=Brewfile
brew bundle cleanup --file=Brewfile --force || true
