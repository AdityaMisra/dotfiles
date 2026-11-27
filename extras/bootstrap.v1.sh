#!/usr/bin/env bash
# Entry point. Runs every install/[0-9]*.sh in order.
# Usage:  ./bootstrap.sh [--dry-run] [--only NN]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "bootstrap.sh: macOS only (detected $(uname -s))" >&2
  exit 1
fi

DRY_RUN=0
ONLY=""
while (($#)); do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --only)       ONLY="${2:?--only needs a step prefix, e.g. 04}"; shift ;;
    --only=*)     ONLY="${1#--only=}" ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--dry-run] [--only NN]

  --dry-run     Print actions without mutating the system.
  --only NN     Run only install/NN-*.sh (e.g. --only 04 for stow).
EOF
      exit 0
      ;;
    *)
      echo "unknown flag: $1" >&2
      exit 2
      ;;
  esac
  shift
done
export DRY_RUN

LOG_DIR="$REPO_ROOT/.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date +%Y%m%d-%H%M%S).log"

echo "==> bootstrap starting (dry-run=$DRY_RUN, only=${ONLY:-all})"
echo "    repo: $REPO_ROOT"
echo "    log:  $LOG_FILE"

shopt -s nullglob
scripts=("$REPO_ROOT"/install/[0-9]*.sh)
shopt -u nullglob

if (( ${#scripts[@]} == 0 )); then
  echo "no install/*.sh scripts found" >&2
  exit 1
fi

for script in "${scripts[@]}"; do
  name="$(basename "$script")"
  if [[ -n "$ONLY" && "$name" != ${ONLY}-* ]]; then
    continue
  fi
  echo
  echo "==> $name"
  if bash "$script" 2>&1 | tee -a "$LOG_FILE"; then
    :
  else
    rc=${PIPESTATUS[0]}
    echo "!! $name failed (exit $rc); see $LOG_FILE" >&2
    exit "$rc"
  fi
done

echo
echo "==> bootstrap done"
