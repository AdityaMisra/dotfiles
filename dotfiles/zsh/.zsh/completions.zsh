autoload -Uz compinit
compinit -C

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

if command -v fzf >/dev/null 2>&1; then
  if [[ -r "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
  elif command -v brew >/dev/null 2>&1; then
    FZF_BASE="$(brew --prefix fzf 2>/dev/null)/shell"
    [[ -r "$FZF_BASE/completion.zsh" ]] && source "$FZF_BASE/completion.zsh"
    [[ -r "$FZF_BASE/key-bindings.zsh" ]] && source "$FZF_BASE/key-bindings.zsh"
  fi
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

if [[ -d "$HOME/.sdkman" ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

if command -v brew >/dev/null 2>&1; then
  HB_PREFIX="$(brew --prefix)"
  if [[ -r "$HB_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HB_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
  if [[ -r "$HB_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HB_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi
  unset HB_PREFIX
fi
