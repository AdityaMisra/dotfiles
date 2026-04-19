# PATH + language toolchain locations.
# Hardcoded versions (Go 1.15.1, area51/flutter) intentionally NOT carried
# forward from dotzshrc_mac — let version managers (asdf/sdkman/nvm) own them.

typeset -U path PATH

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
  "/usr/local/sbin"
)

if [[ -z "${SDKMAN_DIR:-}" && -z "${JAVA_HOME:-}" ]]; then
  if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
  elif /usr/libexec/java_home >/dev/null 2>&1; then
    export JAVA_HOME="$(/usr/libexec/java_home)"
  fi
fi

if [[ -d "$HOME/go" ]]; then
  export GOPATH="$HOME/go"
  path+=("$GOPATH/bin")
fi

if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  path+=(
    "$ANDROID_HOME/tools"
    "$ANDROID_HOME/tools/bin"
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/emulator"
  )
fi

export PATH
