# Filesystem
alias l='lsd -lh'
alias ll='lsd -alFh --all'
alias la='lsd -A'
alias lt='lsd --tree --depth=2'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias rm='rm -i'
alias cdarea='cd ~/area51'

# Disk usage
alias du='duf'
alias df='duf'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Cat replacement
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'

# Git
alias gs='git status'
alias gst='git status -sb'
alias gd='git diff'
alias gco='git checkout'
alias gp='git pull'
alias gpu='git push'
alias gb=git_branch_more
alias gl="git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"

# Django (kept from old dotzshrc_mac, optional)
alias sp='./manage.py shell_plus'
alias db='./manage.py dbshell'
alias runs='./manage.py runserver'
alias runsplus='./manage.py runserver_plus'

# Python ergonomics
alias ipython='ipython --pprint --pdb'
alias pip='pip3'

# Long-running command alert (port from old dotzshrc_mac)
alias alert='osascript -e "display notification \"Command finished\" with title \"Terminal\""'
