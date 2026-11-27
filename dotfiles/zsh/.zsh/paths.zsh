# PATH and toolchains. `typeset -U` de-duplicates entries.
typeset -U path PATH fpath

# Non-login shells (e.g. `zsh` typed inside a shell) may not have run .zprofile.
if [[ -z "$HOMEBREW_PREFIX" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  elif [[ -x /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv zsh)"; fi
fi

path=("$HOME/.local/bin" "$HOME/bin" $path)

# Java: SDKMAN if present, otherwise Homebrew openjdk@21.
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
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
# file, regenerating it only when the tool's binary is newer (i.e. after an upgrade).
# Saves ~100ms per new shell versus running `tool init zsh` every time.
_cached_init() {
  local name=$1; shift
  local bin=${commands[$1]} cache="$XDG_CACHE_HOME/zsh/init-$name.zsh"
  [[ -n $bin ]] || return 0
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    mkdir -p "${cache:h}" && "$@" >| "$cache" 2>/dev/null
  fi
  source "$cache"
}
