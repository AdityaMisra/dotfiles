# Completion system. zsh-completions must be on fpath BEFORE compinit.
fpath=("$HOMEBREW_PREFIX/share/zsh-completions" "$HOMEBREW_PREFIX/share/zsh/site-functions" "$HOME/.zsh/completions" $fpath)

autoload -Uz compinit
_zcompdump="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
mkdir -p "${_zcompdump:h}"
# Full security check at most once a day; otherwise use the cached dump (fast).
if [[ -n $_zcompdump(#qN.mh+24) || ! -f $_zcompdump ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'  # case-insensitive + fuzzy-ish
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion:*' menu no                    # fzf-tab draws the menu

# fzf-tab (must load after compinit, before autosuggestions/highlighting)
if [[ -r "$HOMEBREW_PREFIX/share/fzf-tab/fzf-tab.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/fzf-tab/fzf-tab.zsh"
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:*' fzf-flags --height=50%
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
  zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
fi
