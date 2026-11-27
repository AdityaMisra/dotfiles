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

# Keep obvious secrets out of ~/.zsh_history (atuin applies a similar filter to its DB).
# The command still runs; it just isn't saved. Prefix any command with a space to skip saving.
zshaddhistory() {
  setopt localoptions extendedglob
  [[ $1 != *(#i)(token|secret|passw(or)#d|api[_-]#key|private[_-]#key)*=* ]]
}
