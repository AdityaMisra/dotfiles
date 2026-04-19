# Base Brewfile — applies to every machine.
# Per-machine extras live in hosts/<alias>/Brewfile.work and are applied by
# install/08-host-overlay.sh.
#
# Re-run anytime via:  brew bundle --file=Brewfile
# Drift check via:     brew bundle check --file=Brewfile

# --- Taps -------------------------------------------------------------------
# (homebrew/core, homebrew/cask are built-in since Homebrew 4.x — do NOT tap)

# --- CLI tools (formulae) ---------------------------------------------------
brew "stow"                 # symlink farm manager for dotfiles/
brew "mas"                  # Mac App Store CLI
brew "gh"                   # GitHub CLI
brew "git"
brew "git-lfs"
brew "diff-so-fancy"        # git diff pager
brew "fzf"                  # fuzzy finder
brew "ripgrep"              # rg
brew "bat"                  # cat with wings
brew "lsd"                  # ls with icons
brew "eza"                  # modern ls (kept alongside lsd; preference floats)
brew "jq"                   # JSON
brew "yq"                   # YAML
brew "fx"                   # interactive JSON viewer
brew "duf"                  # disk usage
brew "htop"
brew "btop"
brew "starship"             # prompt
brew "tmux"
brew "neovim"
brew "zoxide"               # smarter cd
brew "tldr"
brew "wget"
brew "coreutils"            # GNU coreutils (gls, gdate, etc.)
brew "pipx"                 # isolated python tool installs
brew "uv"                   # fast python package manager
brew "espanso"              # text expander
brew "imagemagick"
brew "ffmpeg"

# Shell candy
brew "zsh-syntax-highlighting"
brew "zsh-autosuggestions"
brew "zsh-completions"

# --- GUI applications (casks) ----------------------------------------------
cask "ghostty"              # terminal
cask "hammerspoon"          # window mgmt + global hotkeys (replaces spectacle)
cask "raycast"              # launcher
cask "maccy"                # clipboard history

# Comms
cask "slack"
cask "zoom"

# Dev environments
cask "cursor"               # primary editor
cask "visual-studio-code"
cask "jetbrains-toolbox"    # installs IntelliJ IDEA + others
cask "postman"
cask "docker"               # Docker Desktop
cask "orbstack"             # lightweight container/k8s runtime; pick one over time

# Browsers + utilities
cask "google-chrome"
cask "firefox"
cask "rectangle"            # secondary tiling fallback if Hammerspoon misbehaves
cask "appcleaner"
cask "the-unarchiver"

# Fonts
cask "font-jetbrains-mono-nerd-font"
cask "font-fira-code-nerd-font"
