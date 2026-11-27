# ~/.zshrc — interactive shell. Each ~/.zsh/<topic>.zsh owns one concern.
# Order matters: completion before fzf-tab; autosuggestions + syntax highlighting last.

[[ -o interactive ]] || return

for _f in paths options history completions tools aliases functions iterm prompt plugins; do
  [[ -r "$HOME/.zsh/$_f.zsh" ]] && source "$HOME/.zsh/$_f.zsh"
done
unset _f

# Employer-specific shell setup (VPN/cloud logins, internal CLIs, ...) — NOT in git.
# One generic name for whichever company you work at; swap the file when you change jobs.
[[ -r "$HOME/.workrc" ]] && source "$HOME/.workrc"

# Per-machine overrides — NOT in git (created by bootstrap.sh).
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
