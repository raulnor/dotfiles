#!/bin/sh
set -e

PURGE=false
for arg in "$@"; do
    case "$arg" in
        purge) PURGE=true ;;
        --purge) PURGE=true ;;
    esac
done

# Uninstall all packages
if [ "$PURGE" = true ]; then
    while [[ `brew list | wc -l` -ne 0 ]]; do
        for EACH in `brew list`; do
            brew uninstall --force --ignore-dependencies $EACH
        done
    done
fi

# Create temporary Brewfile
cat > /tmp/Brewfile << 'EOF'
tap "rconroy293/seventeenlands", trusted: true
tap "saulpw/vd", trusted: true
brew "ffmpeg"
brew "fzf"
brew "elixir"
brew "gh"
brew "gron"
brew "hugo"
brew "lazygit"
brew "llm"
brew "imagemagick"
brew "npm"
brew "ollama"
brew "python3"
brew "ripgrep"
brew "rconroy293/seventeenlands/seventeenlands"
brew "saulpw/vd/visidata"
brew "yt-dlp"
EOF

# Install packages
brew bundle install --file=/tmp/Brewfile
rm /tmp/Brewfile