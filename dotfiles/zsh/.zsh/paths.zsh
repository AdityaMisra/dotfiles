# PATH and toolchains. `typeset -U` de-duplicates entries.
typeset -U path PATH fpath

# Non-login shells (e.g. `zsh` typed inside a shell) may not have run .zprofile.
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  elif [[ -x /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv zsh)"; fi
fi

path=("$HOME/.local/bin" "$HOME/bin" $path)

# Java & co: SDKMAN if present, otherwise Homebrew openjdk@21.
# Fast path: put each SDKMAN candidate's "current" version on PATH and set JAVA_HOME
# directly, and load the full SDKMAN init (~20ms) only when you first type `sdk`.
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  for _c in "$SDKMAN_DIR"/candidates/*/current(N); do path=("$_c/bin" $path); done; unset _c
  [[ -d "$SDKMAN_DIR/candidates/java/current" ]] && export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"
  sdk() { unfunction sdk; source "$SDKMAN_DIR/bin/sdkman-init.sh"; sdk "$@"; }
elif [[ -d "$HOMEBREW_PREFIX/opt/openjdk@21/bin" ]]; then
  path=("$HOMEBREW_PREFIX/opt/openjdk@21/bin" $path)
fi

# VS Code `code` command
_vsc="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
[[ -d $_vsc ]] && path+=("$_vsc"); unset _vsc

[[ -d "$HOME/go" ]] && { export GOPATH="$HOME/go"; path+=("$GOPATH/bin"); }
[[ -d "$HOME/.cargo/bin" ]] && path+=("$HOME/.cargo/bin")

export PATH

# _cached_init <name> <command...>: source a tool's generated shell setup from a cache
# file instead of running `tool init zsh` on every shell (saves ~100ms).
# The cache records the tool's resolved binary path (Homebrew: .../Cellar/<tool>/<version>/...)
# and the exact command, so it's regenerated after an upgrade or when the flags change.
_cached_init() {
  local name=$1; shift
  local bin=${commands[$1]} cache="$XDG_CACHE_HOME/zsh/init-$name.zsh"
  [[ -n $bin ]] || return 0
  local stamp="# _cached_init: ${bin:A} :: $*"
  if [[ ! -s $cache || "$(head -n1 "$cache")" != "$stamp" ]]; then
    mkdir -p "${cache:h}" && { print -r -- "$stamp"; "$@" 2>/dev/null; } >| "$cache"
  fi
  source "$cache"
}
