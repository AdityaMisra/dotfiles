# Shell integrations for CLI tools. Each is skipped if the tool isn't installed.

# fzf: Ctrl-T (files), Alt-C (cd). Ctrl-R is taken over by atuin below.
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --info=inline'
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons {}'"
  _cached_init fzf fzf --zsh
fi

# zoxide: `z foo` jumps to the most-used dir matching foo; `zi` = interactive.
_cached_init zoxide zoxide init zsh

# atuin: Ctrl-R full-screen fuzzy history (sync disabled in ~/.config/atuin/config.toml).
# Up-arrow stays as prefix search (options.zsh).
_cached_init atuin atuin init zsh --disable-up-arrow

# nvm: lazy-load so it doesn't cost ~300ms at every shell start.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  _nvm_lazy() { unfunction nvm node npm npx 2>/dev/null; source "$NVM_DIR/nvm.sh"; }
  for _c in nvm node npm npx; do eval "$_c() { _nvm_lazy; $_c \"\$@\" }"; done
  unset _c
fi
