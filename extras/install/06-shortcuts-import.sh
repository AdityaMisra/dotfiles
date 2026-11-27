#!/usr/bin/env bash
# macOS `Shortcuts.app` cannot import .shortcut bundles non-interactively.
# This script just opens each .shortcut file; user clicks "Add Shortcut".
source "$(dirname "$0")/_lib.sh"

log "Shortcuts import"

shopt -s nullglob
files=("$REPO_ROOT"/shortcuts/*.shortcut)

if (( ${#files[@]} == 0 )); then
  info "no .shortcut files in shortcuts/ \u2014 skipping"
  exit 0
fi

for f in "${files[@]}"; do
  info "opening $(basename "$f") (click 'Add Shortcut' in the dialog)"
  if dry_run; then
    info "[dry-run] open '$f'"
  else
    open "$f"
    sleep 1
  fi
done
