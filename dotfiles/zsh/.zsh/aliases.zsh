# Listing — eza (replaces lsd)
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias l='eza -lh --icons --git --group-directories-first'
  alias ll='eza -lah --icons --git --group-directories-first'
  alias la='eza -a --icons'
  alias lt='eza --tree --level=2 --icons --git-ignore'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Viewing
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
(( $+commands[duf] )) && alias df='duf'
alias grep='grep --color=auto'

# Git
alias g='git'
alias gs='git status'
alias gst='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gsw='git switch'
alias gp='git pull'
alias gpu='git push'
alias gb=git_branch_more
alias gl="git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"

# Python
alias ipython='ipython --pprint --pdb'
alias pip='pip3'
alias py='python3'

# Claude Code
alias c='claude'
alias cr='claude --resume'
alias cn='claude --continue'   # (not `cc` — that's the C compiler)

# Shell
alias reload='exec zsh'
alias path='print -l $path'
alias alert='osascript -e "display notification \"Command finished\" with title \"Terminal\""'
