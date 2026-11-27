# Native zsh history. Atuin (tools.zsh) records the same commands into its own
# SQLite DB and owns Ctrl-R; this file stays the fallback and feeds Up-arrow search.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000

setopt EXTENDED_HISTORY       # save timestamp + duration
setopt INC_APPEND_HISTORY     # write immediately, not on exit
setopt SHARE_HISTORY          # share across open tabs
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate when a command repeats
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE      # prefix a command with a space to keep it out of history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # !! expansions are shown before running
