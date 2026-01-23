#!/usr/bin/env bash
# install.sh - Install sudo-in-terminal
set -euo pipefail

REPO_URL="https://github.com/falonofthetower/sudo-in-terminal"
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

# Detect if we're running from the repo or via curl
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/sudo-in-terminal" ]]; then
    FROM_REPO=true
else
    FROM_REPO=false
fi

echo ""
echo "┌─────────────────────────────────────┐"
echo "│     sudo-in-terminal installer      │"
echo "└─────────────────────────────────────┘"
echo ""

# Check for required tools
if ! command -v curl &> /dev/null && [[ "$FROM_REPO" == false ]]; then
    error "curl is required for installation"
fi

# Create temp dir if installing from remote
if [[ "$FROM_REPO" == false ]]; then
    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT

    info "Downloading sudo-in-terminal..."
    curl -fsSL "$REPO_URL/raw/main/sudo-in-terminal" -o "$TMPDIR/sudo-in-terminal"
    curl -fsSL "$REPO_URL/raw/main/enable-touchid-sudo" -o "$TMPDIR/enable-touchid-sudo"
    SCRIPT_DIR="$TMPDIR"
fi

# Check if install dir is writable
if [[ -w "$INSTALL_DIR" ]]; then
    SUDO=""
else
    SUDO="sudo"
    info "Installing to $INSTALL_DIR (requires sudo)"
fi

# Install main script
info "Installing sudo-in-terminal to $INSTALL_DIR..."
$SUDO cp "$SCRIPT_DIR/sudo-in-terminal" "$INSTALL_DIR/$SCRIPT_NAME"
$SUDO chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
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
        read -p "Enable Touch ID for sudo? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
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
    read -p "Configure Claude Code to use sudo-in-terminal? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
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
            fi
            success "Added permission to ~/.claude/settings.local.json"
        fi
    fi
else
    echo "Claude Code not detected (~/.claude not found)"
    echo "If you install Claude Code later, run this installer again."
fi

echo ""
echo "┌─────────────────────────────────────┐"
echo "│           Installation complete     │"
echo "└─────────────────────────────────────┘"
echo ""
echo "Usage:"
echo "  sudo-in-terminal <command>"
echo ""
echo "Examples:"
echo "  sudo-in-terminal whoami"
echo "  sudo-in-terminal apt install nginx"
echo ""
