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
