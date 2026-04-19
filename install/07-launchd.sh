#!/usr/bin/env bash
# Installs and bootstraps user launchd agents in ~/Library/LaunchAgents.
# Each plist is templated with the absolute repo path before install.
source "$(dirname "$0")/_lib.sh"

log "launchd agents"

AGENT_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$AGENT_DIR"

shopt -s nullglob
plists=("$REPO_ROOT"/launchd/*.plist)

if (( ${#plists[@]} == 0 )); then
  info "no plists in launchd/ \u2014 skipping"
  exit 0
fi

for src in "${plists[@]}"; do
  name="$(basename "$src")"
  dest="$AGENT_DIR/$name"
  label="${name%.plist}"

  info "installing $name"
  if dry_run; then
    info "[dry-run] template + copy to $dest, then launchctl bootstrap"
    continue
  fi

  # Substitute {{HOME}} and {{REPO_ROOT}} placeholders.
  sed \
    -e "s|{{HOME}}|$HOME|g" \
    -e "s|{{REPO_ROOT}}|$REPO_ROOT|g" \
    "$src" > "$dest"

  # Re-bootstrap to pick up changes.
  launchctl bootout "gui/$UID/$label" >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$UID" "$dest"
  launchctl enable   "gui/$UID/$label"
done
