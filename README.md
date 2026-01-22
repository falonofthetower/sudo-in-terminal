# sudo-in-terminal

Run sudo commands in a separate terminal window for interactive password authentication, with output captured and returned to the caller.

Useful for:
- **CLI tools** that need to run privileged commands but can't handle interactive prompts
- **AI coding assistants** (like Claude Code) that need sudo access
- **Scripts** that require privilege escalation with user confirmation
- **Automation** where you want explicit user approval for sudo operations

## Installation

### Homebrew (macOS/Linux)

```bash
brew install falonofthetower/tap/sudo-in-terminal
```

### Manual

```bash
# Clone the repo
git clone https://github.com/falonofthetower/sudo-in-terminal.git
cd sudo-in-terminal

# Install
make install

# Or manually copy to your PATH
cp sudo-in-terminal /usr/local/bin/
chmod +x /usr/local/bin/sudo-in-terminal
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
3. Waits for you to authenticate with sudo
4. Captures stdout/stderr to a temp file
5. Returns the output to the original caller
6. Cleans up temp files

## Touch ID for sudo (macOS)

On macOS, you can use Touch ID (fingerprint) instead of typing your password for sudo. This makes authentication faster and works great with `sudo-in-terminal`.

### Enable Touch ID for sudo

```bash
# Run the included setup script
./enable-touchid-sudo

# Or with make
make enable-touchid
```

This adds the `pam_tid.so` module to `/etc/pam.d/sudo`.

### Manual setup

Add this line to the top of `/etc/pam.d/sudo` (after the first comment block):

```
auth       sufficient     pam_tid.so
```

### Disable Touch ID for sudo

```bash
sudo sed -i '' '/pam_tid.so/d' /etc/pam.d/sudo
```

### Note on Apple Silicon Macs

Touch ID for sudo works in Terminal.app and most terminal emulators. If you're using tmux, you may need [pam-reattach](https://github.com/fabianishere/pam_reattach) for Touch ID to work inside tmux sessions.

## Claude Code Integration

Add to `~/.claude/CLAUDE.md`:

```markdown
## sudo-in-terminal

When running commands that require `sudo`, use:

\`\`\`bash
sudo-in-terminal <command>
\`\`\`

This opens a separate terminal for password authentication and returns the output.
```

Add to `~/.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(sudo-in-terminal:*)"
    ]
  }
}
```

## License

MIT License - see [LICENSE](LICENSE)
