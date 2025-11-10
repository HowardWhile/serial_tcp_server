#!/bin/bash
# ---------------------------------
# Serial Bridge Launcher 
# ---------------------------------
CONFIG_FILE="./config.ini"
BAUD=115200
declare -A PORTS

# ---------------------------------
# Parse INI configuration
# ---------------------------------
parse_config() {
  local section=""
  while IFS= read -r line; do
    # 去除開頭與結尾空白
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    # 跳過空行與註解
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    # 解析 section
    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
      section="${BASH_REMATCH[1]}"
      continue
    fi
    # 只解析 [ports] 區塊內的 key=value
    if [[ "$section" == "ports" && "$line" =~ ^([^=]+)=(.*)$ ]]; then
      local dev="${BASH_REMATCH[1]}"
      local port="${BASH_REMATCH[2]}"
      PORTS["$dev"]=$port
    fi
  done < "$CONFIG_FILE"
}

# ---------------------------------
start_all() {
# ---------------------------------
  parse_config
  echo "Starting socat TCP servers..."
  for dev in "${!PORTS[@]}"; do
    port=${PORTS[$dev]}
    if [ ! -e "$dev" ]; then
      echo "Warning: $dev not found, skipping."
      continue
    fi
    if pgrep -f "socat.*${dev}" >/dev/null; then
      echo "socat for $dev already running."
      continue
    fi
    echo "Launching $dev on TCP port $port ..."
    nohup socat tcp-l:${port},reuseaddr,fork ${dev},raw,echo=0,b${BAUD} >/dev/null 2>&1 &
  done
  echo "All available serial ports launched."
}

# ---------------------------------
stop_all() {
# ---------------------------------
  echo "Stopping all socat processes..."
  pkill -f "socat.*tty"
  echo "All socat instances stopped."
}

# ---------------------------------
status_all() {
# ---------------------------------
  echo "Currently active socat servers:"
  pgrep -a socat | grep tty || echo "No socat instances running."
}

case "$1" in
  start)
    start_all
    ;;
  stop)
    stop_all
    ;;
  restart)
    stop_all
    sleep 1
    start_all
    ;;
  status)
    status_all
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    ;;
esac
