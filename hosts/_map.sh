#!/usr/bin/env bash
# Resolve LocalHostName -> logical alias used as hosts/<alias>/ directory.
# Add new mappings here as machines are added.
set -euo pipefail

host="$(scutil --get LocalHostName 2>/dev/null || hostname)"

case "$host" in
  WORK-LAPTOP-ID*) echo work-laptop ;;
  *)           echo personal ;;
esac
