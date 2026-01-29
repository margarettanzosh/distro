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
    # For bash shells (including cs50.dev codespaces)
    # Add to .bashrc
    if ! grep -q "export PATH.*aiAssessment" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "# Add AP CSP Assessment tool to PATH" >> ~/.bashrc
        echo 'export PATH="'"$SCRIPT_DIR"':$PATH"' >> ~/.bashrc
        echo "✓ Added to PATH in ~/.bashrc"
    fi
    
    # Ensure .bash_profile sources .bashrc (critical for cs50.dev)
    if [ ! -f ~/.bash_profile ] || ! grep -q "source.*bashrc" ~/.bash_profile 2>/dev/null; then
        echo "" >> ~/.bash_profile
        echo "# Source .bashrc for interactive shells" >> ~/.bash_profile
        echo 'if [ -f ~/.bashrc ]; then source ~/.bashrc; fi' >> ~/.bash_profile
        echo "✓ Configured .bash_profile to load .bashrc"
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
echo "IMPORTANT: Keep your API key secure. Do not share setup.sh after"
echo "           adding your key, as it contains your personal API key."
echo ""
