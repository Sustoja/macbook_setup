#!/bin/bash
set -euo pipefail

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
ZSHRC="$HOME/.zshrc"

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is designed for macOS only"
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed"
fi

# Install packages
brew bundle --no-lock --file=- <<EOF
cask "alacritty"
cask "font-ubuntu-mono-nerd-font"
brew "starship"
brew "fastfetch"
EOF

# Create config directories
mkdir -p "$CONFIG_DIR/alacritty"

# Copy config files
cp "$SCRIPT_DIR/assets/alacritty/alacritty.toml" "$CONFIG_DIR/alacritty/alacritty.toml"
cp "$SCRIPT_DIR/assets/starship/starship.toml" "$CONFIG_DIR/starship.toml"

# Enable hushlogin
touch "$HOME/.hushlogin"

# Add Alacritty-specific configuration to zshrc if not already present
if ! grep -q "TERM.*alacritty" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" <<EOF

# Alacritty-specific configuration
if [ "\$TERM" = "alacritty" ]; then
    fastfetch
    eval "\$(starship init zsh)"
fi
EOF
fi

# Print success message
echo "Installation complete!"
