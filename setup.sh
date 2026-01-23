#!/bin/bash
# AP CSP Assessment Setup Script
# Run this once with: source setup.sh

# REPLACE THIS with your actual Anthropic API key from https://console.anthropic.com
API_KEY='YOUR_API_KEY_HERE'

echo "=========================================="
echo "AP CSP Assessment Tool Setup"
echo "=========================================="
echo ""

# Install required packages
echo "Installing required Python packages..."
pip3 install anthropic rich

# Set API key as environment variable for current session
export ANTHROPIC_API_KEY="$API_KEY"

# Create .env file for persistent storage
echo "# Anthropic API Key for Assessment Tool" > .env
echo "ANTHROPIC_API_KEY='$API_KEY'" >> .env
echo "✓ Created .env file with API key"

# Create load_env.sh script
cat > load_env.sh << 'EOF'
#!/bin/bash
# Load environment variables from .env file
# Run with: source load_env.sh

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✓ Environment variables loaded from .env"
    echo "✓ ANTHROPIC_API_KEY is set"
else
    echo "⚠ .env file not found"
fi
EOF
chmod +x load_env.sh
echo "✓ Created load_env.sh script"

# Add auto-load to shell profile
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ "$SHELL" == *"zsh"* ]]; then
    if ! grep -q "source.*load_env.sh" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo "# Auto-load AP CSP Assessment environment" >> ~/.zshrc
        echo "if [ -f \"$SCRIPT_DIR/load_env.sh\" ]; then" >> ~/.zshrc
        echo "    source \"$SCRIPT_DIR/load_env.sh\"" >> ~/.zshrc
        echo "fi" >> ~/.zshrc
        echo "✓ Added auto-load to ~/.zshrc"
    fi
elif [[ "$SHELL" == *"bash"* ]]; then
    if ! grep -q "source.*load_env.sh" ~/.bash_profile 2>/dev/null; then
        echo "" >> ~/.bash_profile
        echo "# Auto-load AP CSP Assessment environment" >> ~/.bash_profile
        echo "if [ -f \"$SCRIPT_DIR/load_env.sh\" ]; then" >> ~/.bash_profile
        echo "    source \"$SCRIPT_DIR/load_env.sh\"" >> ~/.bash_profile
        echo "fi" >> ~/.bash_profile
        echo "✓ Added auto-load to ~/.bash_profile"
    fi
fi

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "Your API key is now stored in:"
echo "  - .env file (persistent across sessions)"
echo "  - Shell profile (auto-loads on terminal startup)"
echo ""
echo "You can now run assessments with:"
echo "  python3 assess.py your_code.py \"Your Name\""
echo "  python3 assess_rich.py your_code.py \"Your Name\""
echo ""
echo "If the API key isn't loaded, run:"
echo "  source load_env.sh"
echo ""

# Self-destruct for security (removes this script with the API key)
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
echo "Removing setup script for security..."
rm -f "$SCRIPT_PATH"
echo "✓ Setup script deleted. Your API key is safely stored in .env and shell profile."
echo ""
