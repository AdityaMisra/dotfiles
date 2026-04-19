# ~/.zshrc — interactive shell config.
# Modular loader: each .zsh/<topic>.zsh file owns one concern.

[[ $- != *i* ]] && return

ZSH_MODULES_DIR="$HOME/.zsh"

for f in \
  "$ZSH_MODULES_DIR/paths.zsh" \
  "$ZSH_MODULES_DIR/history.zsh" \
  "$ZSH_MODULES_DIR/options.zsh" \
  "$ZSH_MODULES_DIR/aliases.zsh" \
  "$ZSH_MODULES_DIR/functions.zsh" \
  "$ZSH_MODULES_DIR/completions.zsh" \
  "$ZSH_MODULES_DIR/prompt.zsh"
do
  [[ -r "$f" ]] && source "$f"
done

# Per-machine overrides (gitignored; written by install/08-host-overlay.sh).
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
