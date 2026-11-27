#!/usr/bin/env bash
# Generic "work laptop" overlay shipped with the public repo.
# Sourced by install/08-host-overlay.sh.
# Idempotent: every step is guarded by an "already-present" check.
#
# Anything employer-specific (private package indexes, internal CLIs)
# belongs in hosts/<alias>.local/install.sh which is gitignored.
set -euo pipefail

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

JAVA_VERSIONS=("11.0.24-tem" "17.0.12-tem")

# --- SDKMAN + Java + build tools -------------------------------------------
if [[ ! -d "$HOME/.sdkman" ]]; then
  log "installing SDKMAN"
  curl -fsSL https://get.sdkman.io | bash
fi

# shellcheck disable=SC1091
source "$HOME/.sdkman/bin/sdkman-init.sh"

for v in "${JAVA_VERSIONS[@]}"; do
  if sdk list java 2>/dev/null | grep -q "installed.*$v"; then
    log "java $v already installed"
  elif [[ -d "$HOME/.sdkman/candidates/java/$v" ]]; then
    log "java $v already installed (filesystem check)"
  else
    log "installing java $v"
    yes n | sdk install java "$v" || warn "sdk install java $v failed"
  fi
done

for tool in maven gradle; do
  if [[ -d "$HOME/.sdkman/candidates/$tool/current" ]]; then
    log "$tool already installed"
  else
    log "installing $tool"
    yes n | sdk install "$tool" || warn "sdk install $tool failed"
  fi
done

# --- ed25519 SSH key -------------------------------------------------------
KEY="$HOME/.ssh/id_ed25519"
if [[ -f "$KEY" ]]; then
  log "SSH key $KEY already present"
else
  log "generating SSH key $KEY"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -f "$KEY" -N "" -C "$USER@$(scutil --get LocalHostName 2>/dev/null || hostname)"
  warn "Add ${KEY}.pub to GitHub / your identity provider as needed"
fi

log "work-laptop overlay done"
