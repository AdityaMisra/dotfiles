# Sourced by every script in scripts/. Do not run directly.
set -euo pipefail

# Resolve real path of _lib.sh through any symlinks (scripts get symlinked
# into ~/.local/bin via the dotfiles/bin/ stow package).
_lib_real="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null \
  || python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$_lib_real")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APPLESCRIPT_DIR="$REPO_ROOT/applescript"

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

run_applescript() {
  local script="$APPLESCRIPT_DIR/$1"
  shift || true
  [[ -f "$script" ]] || die "missing applescript: $script"
  osascript "$script" "$@"
}

usage() {
  sed -n '/^# usage:/,/^# end/p' "$0" | sed 's/^# \{0,1\}//; s/^usage://; /^end$/d'
}

handle_help() {
  for arg in "$@"; do
    case "$arg" in -h|--help) usage; exit 0 ;; esac
  done
}
