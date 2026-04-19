#!/usr/bin/env bash
# Pull the repo and re-run bootstrap.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

echo "==> git pull --ff-only"
git pull --ff-only

exec "$REPO_ROOT/bootstrap.sh" "$@"
