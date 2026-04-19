# Powerlevel9k is no longer used; starship owns the prompt now.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
