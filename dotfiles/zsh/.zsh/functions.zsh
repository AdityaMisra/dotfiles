# Every local branch with its last-commit time; current branch marked with an arrow.
git_branch_more() {
  emulate -L zsh
  local current k
  current=$(git symbolic-ref --short HEAD 2>/dev/null) || return 1
  for k in $(git for-each-ref --format='%(refname:short)' refs/heads); do
    printf '%s\t%s%s\n' \
      "$(git show -s --format='%Cgreen%ci %Cblue%cr%Creset' "$k")" "$k" \
      "$([[ $k == $current ]] && print -n '  ')"
  done | sort
}

mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# Open a path in IntelliJ IDEA
idea() { open -na "IntelliJ IDEA.app" --args "${@:-.}"; }

# Interactive shell in a throwaway container with $PWD mounted at /work
dockerit() {
  local image="${1:-alpine}"; shift 2>/dev/null
  local sh=/bin/bash; [[ $image == alpine* ]] && sh=/bin/sh
  docker run --rm -it -v "$PWD:/work" -w /work "$image" "$@" "$sh"
}

extract() {
  [[ -f "$1" ]] || { echo "extract: '$1' not a file" >&2; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf  "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.gz)             gunzip  "$1" ;;
    *.zip)            unzip   "$1" ;;
    *.7z)             7z x    "$1" ;;
    *) echo "extract: unsupported format: $1" >&2; return 1 ;;
  esac
}

# Measure shell startup time
zsh-bench() { for i in {1..5}; do /usr/bin/time zsh -i -c exit; done; }
