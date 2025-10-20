#!/bin/sh
# Install various dev tools and configs for a Mac

# WARNING: This is a work in progress!
# It's based on DHH's Omakase, BUT:
# - I don't agree / haven't tried everything in there
# - I'm not (yet) leaving Mac
# - These are only additive changes (no tiling WMs, using Omarchy keybinds to replace Mac keybinds)
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

# Tiling WM

# Hotkeys - https://learn.omacom.io/2/the-omarchy-manual/53/hotkeys

# Desktop background cycler
# Color themed apps
# File manager

# Neovim

# Quick Emojis / Emojis

# Completions 

# Setup shell tools
echo "Setup Shell Tools (fzf zoxide rg eza fd gron)"
brew install fzf zoxide rg eza fd gron
fzf --zsh > ~/.macakase/fzf.zsh
zoxide init --cmd cd zsh > ~/.macakase/zoxide.zsh
cp ${SCRIPT_DIR}/macakase-eza.zsh ~/.macakase/eza.zsh
cp ${SCRIPT_DIR}/macakase-init.zsh ~/.macakase/__init__.zsh
source ~/.zshrc # TODO: Add init installer
echo "Completed Shell Tools - \`open ~/.macakase to view configs\`"

# Shell Functions - compress iso2sd format-disk img2jpg img2jpg-small img2png

# TUIs - Lazygit lazydocker btop impala fastfetch
brew install lazygit
# GUIs (O) - Obsidian Pinta LocalSend LibreOffice Signal mpv "OBS Studio" Kdenlive 
# GUIs (C) - 1Password Typora Dropbox Tailscale Spotify
# Dev Tools - Neovim Alacritty Mise Docker github-cli
# PDFs - Document Viewer Xournal++

# Web App wrapping - WhatsApp Claude YouTube

# Games - Steam RetroArch Minecraft (!) Doom

# Windows VM

# Brew GUI

# Dotfiles / config changing / Defaults explorer

# Fonts

# Multiple monitors

# Keyboard, mouse, trackpad

# Bioauth

# Starship

# Updates