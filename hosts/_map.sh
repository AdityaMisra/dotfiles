#!/usr/bin/env bash
# Resolve LocalHostName -> logical alias used as hosts/<alias>/ directory.
# Add new mappings here as machines are added. Keep this file generic;
# real per-employer mappings can live in hosts/_map.local.sh (gitignored)
# which, if present, is preferred over this file.
set -euo pipefail

if [[ -f "$(dirname "$0")/_map.local.sh" ]]; then
  exec bash "$(dirname "$0")/_map.local.sh"
fi

host="$(scutil --get LocalHostName 2>/dev/null || hostname)"

# Examples — adjust for your machines:
case "$host" in
  *work*|*-corp*) echo work-laptop ;;
  *)              echo personal ;;
esac
