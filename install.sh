#!/usr/bin/env bash
# install.sh - Install sudo-in-terminal
set -eo pipefail

REPO_URL="https://github.com/falonofthetower/sudo-in-terminal"
RAW_URL="https://raw.githubusercontent.com/falonofthetower/sudo-in-terminal/main"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
SCRIPT_NAME="sudo-in-terminal"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo ""
echo "┌─────────────────────────────────────┐"
echo "│     sudo-in-terminal installer      │"
echo "└─────────────────────────────────────┘"
echo ""

# Detect if we're running from the repo or via curl
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "bash" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi

if [[ -n "$SCRIPT_DIR" ]] && [[ -f "$SCRIPT_DIR/sudo-in-terminal" ]]; then
    FROM_REPO=true
else
    FROM_REPO=false
fi

# Check for required tools
if ! command -v curl &> /dev/null; then
    error "curl is required for installation"
fi

# Create temp dir for downloads
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

if [[ "$FROM_REPO" == true ]]; then
    cp "$SCRIPT_DIR/sudo-in-terminal" "$TMPDIR/sudo-in-terminal"
else
    info "Downloading sudo-in-terminal..."
    curl -fsSL "$RAW_URL/sudo-in-terminal" -o "$TMPDIR/sudo-in-terminal"
fi

chmod +x "$TMPDIR/sudo-in-terminal"

# Check if install dir is writable
if [[ -w "$INSTALL_DIR" ]]; then
    USE_SUDO=false
else
    USE_SUDO=true
    info "Installing to $INSTALL_DIR (requires sudo)"
    # Prompt for sudo upfront to cache credentials
    # Use /dev/tty to allow password entry when script is piped
    sudo -v </dev/tty || error "sudo access required for installation"
fi

# Install main script
info "Installing sudo-in-terminal to $INSTALL_DIR..."
if [[ "$USE_SUDO" == true ]]; then
    sudo cp "$TMPDIR/sudo-in-terminal" "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
else
    cp "$TMPDIR/sudo-in-terminal" "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
fi
success "Installed sudo-in-terminal"

# Verify installation
if command -v sudo-in-terminal &> /dev/null; then
    success "sudo-in-terminal is now available in your PATH"
else
    warn "sudo-in-terminal installed but $INSTALL_DIR may not be in your PATH"
    echo "   Add this to your shell profile:"
    echo "   export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""

# macOS Touch ID setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "┌─────────────────────────────────────┐"
    echo "│     Touch ID for sudo (macOS)       │"
    echo "└─────────────────────────────────────┘"
    echo ""

    if grep -q "pam_tid.so" /etc/pam.d/sudo 2>/dev/null; then
        success "Touch ID for sudo is already enabled"
    else
        echo "Touch ID lets you authenticate sudo with your fingerprint."
        echo ""
        read -p "Enable Touch ID for sudo? [y/N] " -n 1 -r TOUCHID_REPLY </dev/tty || TOUCHID_REPLY="n"
        echo ""
        if [[ $TOUCHID_REPLY =~ ^[Yy]$ ]]; then
            info "Enabling Touch ID for sudo..."
            sudo sed -i '' '2a\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
            success "Touch ID for sudo enabled"
        else
            echo "Skipped. Run 'sudo-in-terminal' with password authentication."
        fi
    fi
    echo ""
fi

# Claude Code setup
echo "┌─────────────────────────────────────┐"
echo "│     Claude Code Integration         │"
echo "└─────────────────────────────────────┘"
echo ""

if [[ -d "$HOME/.claude" ]]; then
    read -p "Configure Claude Code to use sudo-in-terminal? [y/N] " -n 1 -r CLAUDE_REPLY </dev/tty || CLAUDE_REPLY="n"
    echo ""
    if [[ $CLAUDE_REPLY =~ ^[Yy]$ ]]; then
        # Add to CLAUDE.md
        CLAUDE_MD="$HOME/.claude/CLAUDE.md"
        if [[ -f "$CLAUDE_MD" ]] && grep -q "sudo-in-terminal" "$CLAUDE_MD" 2>/dev/null; then
            success "CLAUDE.md already configured"
        else
            cat >> "$CLAUDE_MD" << 'EOF'

## sudo-in-terminal

When running commands that require `sudo`, use:

```bash
sudo-in-terminal <command>
```

This opens a separate terminal for password authentication and returns the output.
EOF
            success "Added instructions to ~/.claude/CLAUDE.md"
        fi

        # Add permission to settings
        SETTINGS="$HOME/.claude/settings.local.json"
        if [[ -f "$SETTINGS" ]] && grep -q "sudo-in-terminal" "$SETTINGS" 2>/dev/null; then
            success "Permissions already configured"
        else
            if [[ -f "$SETTINGS" ]]; then
                # Merge into existing settings
                if command -v jq &> /dev/null; then
                    jq '.permissions.allow += ["Bash(sudo-in-terminal:*)"]' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
                    success "Added permission to ~/.claude/settings.local.json"
                else
                    warn "jq not installed - please manually add permission to $SETTINGS"
                    echo '   "Bash(sudo-in-terminal:*)"'
                fi
            else
                cat > "$SETTINGS" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(sudo-in-terminal:*)"
    ]
  }
}
EOF
                success "Added permission to ~/.claude/settings.local.json"
            fi
        fi
    fi
else
    echo "Claude Code not detected (~/.claude not found)"
    echo "If you install Claude Code later, run this installer again."
fi

echo ""
echo "┌─────────────────────────────────────┐"
echo "│        Installation complete        │"
echo "└─────────────────────────────────────┘"
echo ""
echo "Usage:"
echo "  sudo-in-terminal <command>"
echo ""
echo "Examples:"
echo "  sudo-in-terminal whoami"
echo "  sudo-in-terminal apt install nginx"
echo ""
