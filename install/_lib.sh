# Sourced by every install/*.sh. Provides logging + helpers.
# Do NOT execute directly.

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export REPO_ROOT

log()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

dry_run() { [[ "${DRY_RUN:-0}" == "1" ]]; }

run() {
  if dry_run; then
    info "[dry-run] $*"
  else
    "$@"
  fi
}
