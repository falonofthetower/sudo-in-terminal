#!/usr/bin/env bash
# install.sh - Install sudo-in-terminal
set -eo pipefail

RAW_URL="https://raw.githubusercontent.com/falonofthetower/sudo-in-terminal/main"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
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

# Check for curl
command -v curl &> /dev/null || error "curl is required"

# Create install directory
mkdir -p "$INSTALL_DIR" || error "Failed to create $INSTALL_DIR"

# Download and install
info "Downloading sudo-in-terminal..."
curl -fsSL "$RAW_URL/sudo-in-terminal" -o "$INSTALL_DIR/$SCRIPT_NAME" || error "Download failed"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
success "Installed to $INSTALL_DIR/$SCRIPT_NAME"

# Check PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    warn "$INSTALL_DIR is not in your PATH"
    echo ""
    echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
else
    success "sudo-in-terminal is ready to use"
fi

echo ""
if [[ -d "$HOME/.claude" ]]; then
    echo "Tell Claude Code:"
    echo "  \"Read the sudo-in-terminal README and configure yourself to use it\""
else
    echo "Usage: sudo-in-terminal <command>"
    echo "Docs:  https://github.com/falonofthetower/sudo-in-terminal"
fi
echo ""
