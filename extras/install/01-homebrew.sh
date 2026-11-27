#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

log "Homebrew"

if have brew; then
  info "already installed: $(brew --version | head -n1)"
  run brew update
  exit 0
fi

if dry_run; then
  info "[dry-run] install Homebrew via official installer"
  exit 0
fi

NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
