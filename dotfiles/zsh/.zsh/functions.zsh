# Ported from dotzshrc_mac.
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Ported from dotzshrc_mac. Lists every local branch with its last-commit
# timestamp; highlights the current branch with a back-arrow glyph.
git_branch_more() {
  emulate -L zsh
  local current k
  current=$(git symbolic-ref --short HEAD 2>/dev/null) || return 1
  for k in $(git branch | sed 's/^..//'); do
    if [[ "$k" == "$current" ]]; then
      printf '%s\t%s  \uf060\n' \
        "$(git show --pretty=format:'%Cgreen%ci %Cblue%cr%Creset' "$k" | head -n1)" \
        "$k"
    else
      printf '%s\t%s\n' \
        "$(git show --pretty=format:'%Cgreen%ci %Cblue%cr%Creset' "$k" | head -n1)" \
        "$k"
    fi
  done | sort
}

# Ported from live ~/.zshrc — runs an interactive shell in a fresh container,
# mounting the cwd. `dockerit ubuntu` -> bash in a clean ubuntu container.
dockerit() {
  emulate -L zsh
  local image="${1:-alpine}"
  shift || true
  local shell="/bin/bash"
  case "$image" in
    alpine*) shell="/bin/sh" ;;
  esac
  docker run --rm -it \
    -v "$PWD:/work" \
    -w /work \
    "$image" \
    "$@" "$shell"
}

mkcd() {
  mkdir -p -- "$1" && cd -- "$1"
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
    *)                echo "extract: unsupported format: $1" >&2; return 1 ;;
  esac
}
