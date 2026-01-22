#!/bin/bash
# AP CSP Assessment Setup Script
# Run this once with: source setup.sh

echo "=========================================="
echo "AP CSP Assessment Tool Setup"
echo "=========================================="
echo ""

# Install required packages
echo "Installing required Python packages..."
pip3 install anthropic

# Set API key as environment variable
# INSTRUCTOR: Replace YOUR_ANTHROPIC_API_KEY_HERE with your actual Anthropic API key from https://console.anthropic.com
export ANTHROPIC_API_KEY='YOUR_ANTHROPIC_API_KEY_HERE'

# Add to shell profile for persistence
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
if [[ "$SHELL" == *"zsh"* ]]; then
    if ! grep -q "ANTHROPIC_API_KEY" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo "# AP CSP Assessment API Key" >> ~/.zshrc
        echo "export ANTHROPIC_API_KEY='YOUR_ANTHROPIC_API_KEY_HERE'" >> ~/.zshrc
        echo "✓ Added API key to ~/.zshrc (will persist across sessions)"
    fi
elif [[ "$SHELL" == *"bash"* ]]; then
    if ! grep -q "ANTHROPIC_API_KEY" ~/.bash_profile 2>/dev/null; then
        echo "" >> ~/.bash_profile
        echo "# AP CSP Assessment API Key" >> ~/.bash_profile
        echo "export ANTHROPIC_API_KEY='YOUR_ANTHROPIC_API_KEY_HERE'" >> ~/.bash_profile
        echo "✓ Added API key to ~/.bash_profile (will persist across sessions)"
    fi
fi

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "You can now run assessments with:"
echo "  python3 assess.py your_code.py \"Your Name\""
echo ""
echo "The API key is set for this session and saved for future sessions."
echo ""

# Self-destruct for security (removes this script with the API key)
echo "Removing setup script for security..."
rm -f "$SCRIPT_PATH"
echo "✓ Setup script deleted. Your API key is safely stored in your shell profile."
echo ""
