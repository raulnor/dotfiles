#!/bin/sh
# Install various dev tools and configs for a Mac

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
    echo "Homebrew installed"
else
    echo "Homebrew installation found"
fi

# Install packages from Homebrew
echo "Install packages from Homebrew"
brew install fzf zoxide rg eza fd gron
brew install lazygit
brew install nvim alacritty gh 
brew services start rconroy293/seventeenlands/seventeenlands

# Config directory setup (~/.macakase)
echo "Config directory setup (~/.macakase)"
mkdir -p ${HOME}/.macakase
fzf --zsh > ~/.macakase/fzf.zsh
zoxide init --cmd z zsh > ~/.macakase/zoxide.zsh
cp ${SCRIPT_DIR}/macakase-eza.zsh ~/.macakase/eza.zsh
cp ${SCRIPT_DIR}/macakase-init.zsh ~/.macakase/__init__.zsh
source ~/.zshrc # TODO: Add init installer

# Complete
echo "Setup complete - \`open ~/.macakase\` to view configs"
