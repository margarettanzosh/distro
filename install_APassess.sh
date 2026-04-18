#!/bin/bash
# Install APassess tools to ~/aiAssessments and make commands available on PATH.

set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/aiAssessments"
SKIP_KEY_SETUP=0
RAW_BASE_URL="${APASSESS_RAW_BASE_URL:-https://raw.githubusercontent.com/margarettanzosh/code_assess/main}"

if [ "$1" = "--skip-key" ]; then
    SKIP_KEY_SETUP=1
fi

print_step() {
    echo "[+] $1"
}

download_file() {
    local source_url="$1"
    local dest_path="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$source_url" -o "$dest_path"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$dest_path" "$source_url"
    else
        echo "[!] Neither curl nor wget is installed."
        return 1
    fi
}

install_tool() {
    local file_name="$1"
    local source_path="$SOURCE_DIR/$file_name"
    local target_path="$TARGET_DIR/$file_name"
    local source_url="$RAW_BASE_URL/$file_name"

    if [ -f "$source_path" ]; then
        cp "$source_path" "$target_path"
        print_step "Copied $file_name from local folder"
    else
        print_step "Downloading $file_name from $source_url"
        download_file "$source_url" "$target_path"
    fi
}

print_step "Installing APassess tools to $TARGET_DIR"
mkdir -p "$TARGET_DIR"

# Install tools (local copy first; GitHub download fallback)
install_tool "APassess"
install_tool "read_transcript.py"
install_tool "view_transcript"
install_tool "README_APassess.md"

# Optional lowercase launcher for convenience
cp "$TARGET_DIR/APassess" "$TARGET_DIR/apassess"

chmod +x "$TARGET_DIR/APassess" "$TARGET_DIR/apassess" "$TARGET_DIR/view_transcript" "$TARGET_DIR/read_transcript.py"

print_step "Installing required Python packages"
pip3 install anthropic rich python-dotenv

# API key setup
ENV_FILE="$TARGET_DIR/.env"
if [ "$SKIP_KEY_SETUP" -eq 0 ]; then
    if [ ! -f "$ENV_FILE" ] || ! grep -q '^ANTHROPIC_API_KEY=' "$ENV_FILE" 2>/dev/null; then
        if [ -n "$ANTHROPIC_API_KEY" ]; then
            echo "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" > "$ENV_FILE"
            print_step "Saved existing ANTHROPIC_API_KEY from environment to $ENV_FILE"
        else
            echo
            echo "Enter your Anthropic API key (starts with sk-ant-), or press Enter to skip:"
            read -r API_KEY
            if [ -n "$API_KEY" ]; then
                echo "ANTHROPIC_API_KEY=$API_KEY" > "$ENV_FILE"
                print_step "Saved API key to $ENV_FILE"
            else
                echo "[!] Skipped API key setup. You can set it later in $ENV_FILE"
            fi
        fi
    else
        print_step "API key already present in $ENV_FILE"
    fi
else
    print_step "Skipping API key setup (--skip-key)"
fi

add_path_line() {
    local file="$1"
    if [ ! -f "$file" ]; then
        touch "$file"
    fi

    if ! grep -Fq 'export PATH="$HOME/aiAssessments:$PATH"' "$file"; then
        {
            echo
            echo '# APassess tools'
            echo 'export PATH="$HOME/aiAssessments:$PATH"'
        } >> "$file"
        print_step "Added ~/aiAssessments to PATH in $file"
    fi
}

add_path_line "$HOME/.zshrc"
add_path_line "$HOME/.bashrc"
add_path_line "$HOME/.profile"

# Make available in current shell too
export PATH="$HOME/aiAssessments:$PATH"

echo
print_step "Install complete"
echo
cat <<EOF
Commands you can run now:
  APassess your_program.py "Student Name"
  apassess your_program.py "Student Name"
  view_transcript

Optional installer flag:
    bash install_APassess.sh --skip-key

Optional GitHub override:
    APASSESS_RAW_BASE_URL=https://raw.githubusercontent.com/<owner>/<repo>/<branch> bash install_APassess.sh --skip-key

If a new terminal does not recognize the commands yet, run:
  source ~/.zshrc
EOF
