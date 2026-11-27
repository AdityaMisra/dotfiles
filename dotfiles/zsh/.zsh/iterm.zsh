# iTerm2 helpers. Shell integration itself is loaded automatically by iTerm
# ("Load Shell Integration Automatically" in the Dotfiles profile).
[[ "$TERM_PROGRAM" == "iTerm.app" ]] || return 0

_ITERM_PROFILES="$HOME/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json"
_ITERM_THEME_FILE="$XDG_STATE_HOME/iterm-theme"

_iterm_set_profile() { printf '\e]1337;SetProfile=%s\a' "$1"; }

# theme            pick a colour theme with fzf (live in this tab, remembered for new tabs)
# theme <name>     switch to a theme by name
# theme list       list themes
# theme current    show the active theme
# theme reset      back to the default Dotfiles theme
theme() {
  local -a names
  names=("${(@f)$(jq -r '.Profiles[] | select(.Tags|index("theme")) | .Name' "$_ITERM_PROFILES" 2>/dev/null)}")
  (( ${#names} )) || { echo "theme: no themes found in $_ITERM_PROFILES" >&2; return 1; }

  local pick="$*"
  case "$pick" in
    list)  print -l $names; return ;;
    current)
      if [[ -r "$_ITERM_THEME_FILE" ]]; then print -r -- "$(<"$_ITERM_THEME_FILE")"
      else print "$_ITERM_DEFAULT_THEME (default)"; fi
      return ;;
    reset) command rm -f "$_ITERM_THEME_FILE"; _iterm_set_profile Dotfiles; return ;;
    "")    pick=$(print -l $names | fzf --prompt="theme (now: $(theme current))> " --height=50% --reverse) || return ;;
  esac
  (( ${names[(Ie)$pick]} )) || { echo "theme: unknown '$pick' (try: theme list)" >&2; return 1; }

  _iterm_set_profile "$pick"
  if [[ $pick == $_ITERM_DEFAULT_THEME ]]; then command rm -f "$_ITERM_THEME_FILE"   # default: nothing to re-apply
  else mkdir -p "${_ITERM_THEME_FILE:h}" && print -r -- "$pick" > "$_ITERM_THEME_FILE"; fi
}

# New tabs/windows open with the "Dotfiles" profile, which already uses the default theme's
# colours. Re-apply a remembered theme only when it's a different one: a profile switch
# makes iTerm redraw the whole tab, which shows up as a flicker when a tab opens.
_ITERM_DEFAULT_THEME="Catppuccin Mocha"   # keep in sync with _default_theme in iterm/base.json
if [[ "$ITERM_PROFILE" == "Dotfiles" && -r "$_ITERM_THEME_FILE" ]]; then
  _t="$(<"$_ITERM_THEME_FILE")"
  [[ $_t != $_ITERM_DEFAULT_THEME ]] && _iterm_set_profile "$_t"
  unset _t
fi

# Tab title: the current git repo name (or folder name outside a repo).
#   "repo" at the prompt, "repo ▸ cmd" while a command runs (e.g. "dotfiles ▸ claude").
# Sent as the iTerm user variable "title"; the Dotfiles profile's Custom Tab Title shows "\(user.title)".
# Claude Code is told not to set titles (CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1 in ~/.claude/settings.json).
_iterm_repo=""
_iterm_set_title() { printf '\e]1337;SetUserVar=title=%s\a' "$(print -rn -- "$1" | base64)"; }
_iterm_precmd() {
  local top
  if [[ $PWD == $HOME ]]; then _iterm_repo="~"
  elif top=$(git rev-parse --show-toplevel 2>/dev/null); then _iterm_repo=${top:t}
  else _iterm_repo=${PWD:t}; fi
  _iterm_set_title "$_iterm_repo"
}
_iterm_preexec() { local -a w=(${(z)1}); _iterm_set_title "$_iterm_repo ▸ ${w[1]:t}"; }
autoload -Uz add-zsh-hook
add-zsh-hook precmd _iterm_precmd
add-zsh-hook preexec _iterm_preexec
