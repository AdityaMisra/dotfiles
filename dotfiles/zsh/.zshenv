# ~/.zshenv — sourced by every zsh (login, interactive, scripts). Keep it tiny.
# NOTE: don't set ZDOTDIR here; iTerm2's automatic shell integration relies on it.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Default editor (git commits, Ctrl-X Ctrl-E, ...): Zed, then VS Code, then vim.
if [[ -x /usr/local/bin/zed || -x /opt/homebrew/bin/zed ]]; then
  export EDITOR="zed --wait"
elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
  export EDITOR="'/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' --wait"
else
  export EDITOR="vim"
fi
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R -F -i -M"   # colours, quit if one screen, smart-case search, verbose prompt
