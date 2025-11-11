#!/bin/sh
# Install various dev tools and configs for a Mac

# WARNING: This is a work in progress!
# It's based on DHH's Omakase, BUT:
# - I don't agree / haven't tried everything in there - items I haven't cleared are TODOs or [wrapped]
# - I'm not (yet) leaving Mac
# - These are only additive changes 
#   - no tiling WMs, 
#   - no replacing Mac keybinds with Omarchy keybinds
#   - explicitly disabled items marked with NOOP
# zsh ~/Code/travis-mark/dotfiles/bin/macakase.sh

# Grab directory of running script
if [ -n "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else 
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# Look for and install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed"
fi

# Create config directory
mkdir -p ${HOME}/.macakase

# NOOP: Tiling WM

# NOOP: Hotkeys - https://learn.omacom.io/2/the-omarchy-manual/53/hotkeys

# TODO: Desktop background cycler
# TODO: Color themed apps
# TODO: File manager

# TODO: Neovim (defaults?)

# TODO: Quick Emojis / Emojis

# TODO: Completions 

# Setup shell tools
echo "Setup Shell Tools (fzf zoxide rg eza fd gron)"
brew install fzf zoxide rg eza fd gron
fzf --zsh > ~/.macakase/fzf.zsh
zoxide init --cmd cd zsh > ~/.macakase/zoxide.zsh
cp ${SCRIPT_DIR}/macakase-eza.zsh ~/.macakase/eza.zsh
cp ${SCRIPT_DIR}/macakase-init.zsh ~/.macakase/__init__.zsh
source ~/.zshrc # TODO: Add init installer
echo "Completed Shell Tools - \`open ~/.macakase to view configs\`"

# TODO: Shell Functions - compress iso2sd format-disk img2jpg img2jpg-small img2png

# TODO: TUIs - Lazygit [lazydocker btop impala fastfetch]
brew install lazygit
# TODO: GUIs (O) - Obsidian Pinta LocalSend LibreOffice Signal mpv "OBS Studio" Kdenlive 
# TODO: GUIs (C) - 1Password Typora Dropbox Tailscale Spotify
# TODO: Dev Tools - Neovim Alacritty [Mise Docker] github-cli
brew install nvim alacritty gh 
# TODO: PDFs - Document Viewer Xournal++

# TODO: Web App wrapping - WhatsApp Claude YouTube

# TODO: Games - Steam RetroArch Minecraft (!) Doom

# TODO: Windows VM

# TODO: Brew GUI

# TODO: Dotfiles / config changing / Defaults explorer

# NOOP: Fonts

# NOOP: Multiple monitors

# NOOP: Keyboard, mouse, trackpad

# NOOP: Bioauth

# TODO: Starship

# TODO: Updates