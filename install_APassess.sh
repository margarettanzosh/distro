#!/bin/bash
# Install APassess tools, preferring the same directory as existing assess.

set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_TARGET_DIR="$HOME/aiAssessments"
TARGET_DIR="${APASSESS_TARGET_DIR:-$DEFAULT_TARGET_DIR}"
RAW_BASE_URL="${APASSESS_RAW_BASE_URL:-https://raw.githubusercontent.com/margarettanzosh/code_assess/main}"

# If assess already exists, install alongside it unless APASSESS_TARGET_DIR is set.
if [ -z "$APASSESS_TARGET_DIR" ]; then
    ASSESS_PATH="$(command -v assess 2>/dev/null || true)"
    if [ -n "$ASSESS_PATH" ]; then
        TARGET_DIR="$(cd "$(dirname "$ASSESS_PATH")" && pwd)"
    fi
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

# Optional lowercase launcher for convenience
cp "$TARGET_DIR/APassess" "$TARGET_DIR/apassess"

chmod +x "$TARGET_DIR/APassess" "$TARGET_DIR/apassess" "$TARGET_DIR/view_transcript" "$TARGET_DIR/read_transcript.py"

print_step "Installing required Python packages"
pip3 install anthropic rich python-dotenv

# API key setup
ENV_FILE="$TARGET_DIR/.env"
if [ ! -f "$ENV_FILE" ] || ! grep -q '^ANTHROPIC_API_KEY=' "$ENV_FILE" 2>/dev/null; then
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" > "$ENV_FILE"
        print_step "Saved existing ANTHROPIC_API_KEY from environment to $ENV_FILE"
    fi
fi

add_path_line() {
    local file="$1"
    local path_entry="$2"
    if [ ! -f "$file" ]; then
        touch "$file"
    fi

    if ! grep -Fq "export PATH=\"$path_entry:\$PATH\"" "$file"; then
        {
            echo
            echo '# APassess tools'
            echo "export PATH=\"$path_entry:\$PATH\""
        } >> "$file"
        print_step "Added $path_entry to PATH in $file"
    fi
}

add_path_line "$HOME/.zshrc" "$TARGET_DIR"
add_path_line "$HOME/.bashrc" "$TARGET_DIR"
add_path_line "$HOME/.profile" "$TARGET_DIR"

# Make available in current shell too
export PATH="$TARGET_DIR:$PATH"

echo "APassess installed."

# Delete installer after successful run unless KEEP_INSTALLER=1 is set.
if [ "${KEEP_INSTALLER:-0}" != "1" ]; then
        rm -f "$0" 2>/dev/null || true
fi
