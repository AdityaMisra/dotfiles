# Shared helpers for scripts/*. Sourced, never run directly.
# Scripts are reached through symlinks in ~/.local/bin, so they locate this file via
# their resolved path:  source "$(dirname "$(readlink -f "$0")")/_lib.sh"
set -euo pipefail

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# Print the "# usage: ... # end" block at the top of the calling script.
usage() {
  sed -n '/^# usage:/,/^# end/p' "$0" | sed 's/^# \{0,1\}//; s/^usage://; /^end$/d'
}

handle_help() {
  local arg
  for arg in "$@"; do
    case "$arg" in -h|--help) usage; exit 0 ;; esac
  done
}
