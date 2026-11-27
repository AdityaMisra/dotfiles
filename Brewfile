# Everything Homebrew installs on a new Mac. Applied by ./bootstrap.sh (brew bundle).
# Drift check: brew bundle check --file=Brewfile
# Apps already in /Applications (installed by hand or by IT) are skipped, not reinstalled.
# Machine- or employer-specific extras go in Brewfile.local (not in git), which bootstrap also applies.

# --- Core -------------------------------------------------------------------
brew "git"
brew "gh"                      # GitHub CLI
brew "stow"                    # symlinks dotfiles/<pkg> into ~
brew "jq"
brew "gitleaks"                # secret scanner used by .githooks/pre-commit
brew "bash"                    # modern bash (macOS ships 3.2)

# --- Shell + prompt + history -------------------------------------------------
brew "starship"                # prompt
brew "atuin"                   # Ctrl-R history search (SQLite)
brew "zsh-completions"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "fzf-tab"                 # fuzzy Tab completion

# --- Modern CLI -----------------------------------------------------------------
brew "fzf"
brew "fd"
brew "ripgrep"
brew "bat"
brew "eza"                     # ls replacement (icons, git status, tree)
brew "zoxide"
brew "git-delta"               # git diff pager
brew "duf"
brew "btop"
brew "htop"
brew "fx"                      # interactive JSON viewer
brew "tlrc"                    # tldr pages client (`tldr git`)
brew "wget"

# --- Dev tooling ------------------------------------------------------------------
brew "awscli"
brew "uv"                      # Python packages/tools (see uv-tools.txt)
brew "ipython"                 # better Python REPL (config: dotfiles/ipython)
brew "jira-cli"
brew "googleworkspace-cli"     # gws: Google Docs/Sheets/Drive from the terminal

# --- Terminal, editors, AI ----------------------------------------------------------
# iTerm2 is installed by bootstrap.sh only if missing.
cask "font-jetbrains-mono-nerd-font"
cask "claude-code"
cask "copilot-cli"
cask "codexbar"                # AI usage meter in the menu bar
cask "zed"
cask "visual-studio-code"      # extensions: dotfiles/vscode/extensions.txt
cask "sublime-text"
cask "orbstack"                # Docker/Linux VMs

# --- Apps ---------------------------------------------------------------------------
cask "google-chrome"
cask "safari-technology-preview"
cask "slack"
cask "zoom"
cask "whatsapp"
cask "notion"
cask "obsidian"
cask "microsoft-onenote"
cask "google-drive"
cask "raycast"                 # launcher
cask "rectangle"               # window snapping
cask "itsycal"                 # menu-bar calendar
cask "flux-app"                # f.lux screen colour temperature
