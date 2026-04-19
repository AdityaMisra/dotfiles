#!/usr/bin/env bash
# Maps the current LocalHostName -> a logical alias under hosts/, then runs
# whatever Brewfile.work / install.sh / zshrc.local that overlay defines.
source "$(dirname "$0")/_lib.sh"

log "host overlay"

ALIAS="$(bash "$REPO_ROOT/hosts/_map.sh")"
DIR="$REPO_ROOT/hosts/$ALIAS"

info "alias: $ALIAS"

if [[ ! -d "$DIR" ]]; then
  info "no overlay directory for $ALIAS \u2014 skipping"
  exit 0
fi

if [[ -f "$DIR/Brewfile.work" ]]; then
  info "applying $DIR/Brewfile.work"
  if dry_run; then
    if have brew; then
      brew bundle check --file="$DIR/Brewfile.work" --verbose 2>&1 | sed 's/^/    /' || true
    else
      info "[dry-run] brew not yet installed; would run brew bundle --file=$DIR/Brewfile.work"
    fi
  else
    brew bundle --file="$DIR/Brewfile.work"
  fi
fi

if [[ -f "$DIR/install.sh" ]]; then
  info "running $DIR/install.sh"
  if dry_run; then
    info "[dry-run] bash $DIR/install.sh"
  else
    bash "$DIR/install.sh"
  fi
fi

if [[ -f "$DIR/zshrc.local" ]]; then
  info "installing $DIR/zshrc.local -> ~/.zshrc.local"
  run cp "$DIR/zshrc.local" "$HOME/.zshrc.local"
fi
