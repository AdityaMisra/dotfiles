#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

log "post-install checklist"

cat <<'EOF'

  Bootstrap finished. Manual follow-ups:

  1. Open Hammerspoon.app and grant Accessibility permission
     (System Settings > Privacy & Security > Accessibility).
  2. Open Karabiner-Elements (if installed) and import the Hyper key
     mapping (caps_lock -> ctrl+option+cmd+shift). See README.
  3. Sign in to:
       - GitHub:    gh auth login
       - JetBrains Toolbox (if applicable)
       - Slack, Zoom
  4. Grant Full Disk Access to Terminal/Ghostty if you want backup to
     reach ~/Library files.
  5. Reload your shell:  exec zsh
  6. Verify:  starship --version && stow --version && brew bundle check
  7. If Cursor/Code extensions did not install, run their CLIs manually:
       xargs -L1 cursor --install-extension < dotfiles/cursor/extensions.txt
       xargs -L1 code   --install-extension < dotfiles/vscode/extensions.txt

EOF
