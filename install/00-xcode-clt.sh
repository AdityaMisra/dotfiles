#!/usr/bin/env bash
# Ensures Xcode Command Line Tools are present (provides git, make, clang).
source "$(dirname "$0")/_lib.sh"

log "Xcode Command Line Tools"

if xcode-select -p >/dev/null 2>&1; then
  info "already installed at $(xcode-select -p)"
  exit 0
fi

if dry_run; then
  info "[dry-run] xcode-select --install"
  exit 0
fi

xcode-select --install || true
warn "An Apple GUI dialog has been triggered. Finish the install, then re-run bootstrap.sh."
exit 0
