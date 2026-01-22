PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

.PHONY: install uninstall test enable-touchid disable-touchid

install:
	@mkdir -p $(BINDIR)
	@cp sudo-in-terminal $(BINDIR)/sudo-in-terminal
	@chmod +x $(BINDIR)/sudo-in-terminal
	@echo "Installed sudo-in-terminal to $(BINDIR)/sudo-in-terminal"

uninstall:
	@rm -f $(BINDIR)/sudo-in-terminal
	@echo "Uninstalled sudo-in-terminal"

test:
	@echo "Running basic tests..."
	@./sudo-in-terminal --help > /dev/null && echo "✓ Help flag works"
	@./sudo-in-terminal --version > /dev/null && echo "✓ Version flag works"
	@echo "Tests passed!"

enable-touchid:
	@chmod +x enable-touchid-sudo
	@./enable-touchid-sudo

disable-touchid:
	@echo "Disabling Touch ID for sudo..."
	@sudo sed -i '' '/pam_tid.so/d' /etc/pam.d/sudo
	@echo "✓ Touch ID for sudo disabled"
