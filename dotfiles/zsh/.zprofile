# ~/.zprofile — login shells (iTerm opens login shells by default).

# Homebrew (Apple Silicon first, Intel fallback)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv zsh)"
fi

# Docker Desktop CLI tools
[[ -d "$HOME/.docker/bin" ]] && path+=("$HOME/.docker/bin")

# OrbStack CLI integration
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"
