#!/bin/bash
# AP CSP Assessment Setup Script
# Run this once with: source setup.sh

# REPLACE THIS with your actual API key from google classroom
API_KEY='YOUR_API_KEY_HERE'

echo "=========================================="
echo "AP CSP Assessment Tool Setup"
echo "=========================================="
echo ""

# Install required packages
echo "Installing required Python packages..."
pip3 install anthropic rich python-dotenv

# Create .env file for persistent storage
echo "# Anthropic API Key for Assessment Tool" > .env
echo "ANTHROPIC_API_KEY='$API_KEY'" >> .env
echo "✓ Created .env file with API key"

# Make scripts executable
chmod +x assess 2>/dev/null
echo "✓ Made assessment script executable"

# Add project directory to PATH
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ "$SHELL" == *"zsh"* ]]; then
    if ! grep -q "export PATH.*aiAssessment" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo "# Add AP CSP Assessment tool to PATH" >> ~/.zshrc
        echo 'export PATH="'"$SCRIPT_DIR"':$PATH"' >> ~/.zshrc
        echo "✓ Added to PATH in ~/.zshrc"
    fi
elif [[ "$SHELL" == *"bash"* ]]; then
    # Check for .bashrc first (used by codespaces), then .bash_profile
    if [ -f ~/.bashrc ]; then
        BASH_CONFIG=~/.bashrc
    else
        BASH_CONFIG=~/.bash_profile
    fi
    
    if ! grep -q "export PATH.*aiAssessment" "$BASH_CONFIG" 2>/dev/null; then
        echo "" >> "$BASH_CONFIG"
        echo "# Add AP CSP Assessment tool to PATH" >> "$BASH_CONFIG"
        echo 'export PATH="'"$SCRIPT_DIR"':$PATH"' >> "$BASH_CONFIG"
        echo "✓ Added to PATH in $BASH_CONFIG"
    fi
fi

# Export PATH for current session
export PATH="$SCRIPT_DIR:$PATH"

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "Your API key is stored in .env and will be automatically loaded."
echo ""
echo "You can now run assessments with:"
echo "  assess scrabble.c \"Your Name\""
echo "  assess mario.py"
echo ""
echo "(In new terminals, the PATH will be automatically set)"
echo ""

# Self-destruct for security (removes this script with the API key)
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
echo "Removing setup script for security..."
rm -f "$SCRIPT_PATH"
echo "✓ Setup script deleted."
echo ""
