# ~/.zshenv — sourced for every zsh invocation (login, interactive, scripts).
# Keep it minimal; defer interactive setup to ~/.zshrc.

export ZDOTDIR="${ZDOTDIR:-$HOME}"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR="${EDITOR:-cursor --wait}"
export VISUAL="$EDITOR"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R}"
