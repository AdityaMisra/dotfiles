setopt AUTO_CD              # type a directory name to cd into it
setopt AUTO_PUSHD           # cd pushes onto the dir stack (cd -<TAB> to go back)
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS # allow # comments at the prompt
setopt NO_BEEP
setopt EXTENDED_GLOB
setopt NO_FLOW_CONTROL      # free up Ctrl-S / Ctrl-Q
unsetopt PROMPT_SP          # no stray "%" after output without trailing newline

# Emacs-style line editing (Ctrl-A/E/W/U, Alt-B/F)
bindkey -e

# Up/Down: search history for commands starting with what's already typed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# Ctrl-X Ctrl-E: edit current command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Word motions stop at / . - _ (nicer Alt-Backspace on paths)
WORDCHARS='*?[]~&;!#$%^(){}<>'
