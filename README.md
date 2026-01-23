# sudo-in-terminal

Run sudo commands in a separate terminal window for interactive password authentication, with output captured and returned to the caller.

Useful for:
- **CLI tools** that need to run privileged commands but can't handle interactive prompts
- **AI coding assistants** (like Claude Code) that need sudo access
- **Scripts** that require privilege escalation with user confirmation
- **Automation** where you want explicit user approval for sudo operations

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/falonofthetower/sudo-in-terminal/main/install.sh | bash
```

The installer will:
1. Install `sudo-in-terminal` to `/usr/local/bin`
2. Optionally enable Touch ID for sudo (macOS)
3. Optionally configure Claude Code integration

### Manual Install

```bash
git clone https://github.com/falonofthetower/sudo-in-terminal.git
cd sudo-in-terminal
./install.sh
```

Or copy the script directly:

```bash
sudo curl -fsSL https://raw.githubusercontent.com/falonofthetower/sudo-in-terminal/main/sudo-in-terminal -o /usr/local/bin/sudo-in-terminal
sudo chmod +x /usr/local/bin/sudo-in-terminal
```

## Usage

```bash
sudo-in-terminal <command> [args...]
```

### Examples

```bash
# Run whoami as root
sudo-in-terminal whoami

# Install a package
sudo-in-terminal apt install nginx

# Restart a service
sudo-in-terminal systemctl restart docker

# With custom timeout (60 seconds)
sudo-in-terminal -t 60 long-running-command
```

### Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-v, --version` | Show version number |
| `-t, --timeout <sec>` | Timeout in seconds (default: 300) |
| `-w, --window <name>` | Tmux window name (default: sudo-auth) |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `SUDO_TERMINAL_TIMEOUT` | Default timeout in seconds |
| `SUDO_TERMINAL_WINDOW_NAME` | Default tmux window name |

## Behavior

| Environment | Action |
|-------------|--------|
| Inside tmux | Opens/reuses a window named `sudo-auth` |
| macOS | Opens a new Terminal.app window |
| Linux (GNOME) | Opens a new gnome-terminal window |
| Linux (KDE) | Opens a new Konsole window |
| Linux (fallback) | Opens a new xterm window |

## How It Works

1. Creates a temporary script with your command
2. Opens a new terminal window and runs the script
3. Waits for you to authenticate with sudo (password or Touch ID)
4. Captures stdout/stderr to a temp file
5. Returns the output to the original caller
6. Cleans up temp files

## Touch ID for sudo (macOS)

The installer will offer to enable Touch ID for sudo. You can also enable it manually:

```bash
# Enable
sudo sed -i '' '2a\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo

# Disable
sudo sed -i '' '/pam_tid.so/d' /etc/pam.d/sudo
```

**Note:** If using tmux, you may need [pam-reattach](https://github.com/fabianishere/pam_reattach) for Touch ID to work inside tmux sessions.

## Claude Code Integration

The installer can configure Claude Code automatically. For manual setup:

**~/.claude/CLAUDE.md:**
```markdown
## sudo-in-terminal

When running commands that require `sudo`, use:
sudo-in-terminal <command>

This opens a separate terminal for password authentication and returns the output.
```

**~/.claude/settings.local.json:**
```json
{
  "permissions": {
    "allow": [
      "Bash(sudo-in-terminal:*)"
    ]
  }
}
```

## Uninstall

```bash
sudo rm /usr/local/bin/sudo-in-terminal
```

## License

MIT License - see [LICENSE](LICENSE)
