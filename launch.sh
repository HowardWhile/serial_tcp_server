#!/bin/bash
# ================================================================
#  Serial TCP Server - Launch Script
# ================================================================
#  Version: 0.1.0
#  Author: Howard Cheng
#  Created: 2025-11-10
#  License: MIT
#
#  Description:
#    This script manages multiple serial-to-TCP bridges using 'socat'.
#    Each serial device defined in 'config.ini' will be exposed as
#    a TCP server port, allowing remote connections over the network.
#
# ================================================================

CONFIG_FILE="./config.ini"
BAUD=115200
declare -A PORTS

# ---------------------------------
# Parse INI configuration
# ---------------------------------
function parse_config()
{
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
function start_all()
# ---------------------------------
{
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
function stop_all()
# ---------------------------------
{
  echo "Stopping all socat processes..."

  # 找出所有 tcp-l: 的 socat 進程 PID
  local pids
  pids=$(pgrep -a socat | grep "tcp-l:" | awk '{print $1}')

  if [ -z "$pids" ]; then
    echo "No socat instances found."
    return
  fi

  # 逐一殺掉
  echo "$pids" | while read -r pid; do
    echo "Killing socat PID $pid"
    kill "$pid"
  done

  echo "All socat instances stopped."
}

# ---------------------------------
function status_all()
# ---------------------------------
{
  echo "Currently active socat servers:"
  
  # 取得所有 socat 進程 (僅包含 tcp-l: 的橋接)
  local socat_list
  socat_list=$(pgrep -a socat | grep "tcp-l:")

  if [ -z "$socat_list" ]; then
    echo "No socat instances running."
    return
  fi

  echo
  echo "[ Raw Command Lines ]"
  echo "$socat_list"
  echo

  echo "[ Parsed Connections ]"
  echo "$socat_list" | while read -r line; do
    # 從字串中萃取 TCP port 與最後的 device 名稱
    port=$(echo "$line" | sed -nE 's/.*tcp-l:([0-9]+).*/\1/p')
    dev=$(echo "$line" | awk '{print $NF}')
    if [ -n "$port" ] && [ -n "$dev" ]; then
      printf "  Port %-5s → %s\n" "$port" "$dev"
    else
      # 如果格式不符，保留原始行（保險機制）
      echo "  $line"
    fi
  done
  echo
}
# ---------------------------------
function version_info()
# ---------------------------------
{
  echo "----------------------------------------"
  echo " Serial TCP Server - Launch Script"
  echo "----------------------------------------"
  echo "Project Version : 0.1.0"
  echo "Author          : Howard Cheng"
  echo "License         : MIT"
  echo
  if command -v socat >/dev/null 2>&1; then
    echo "Socat Version   :"
    socat -V 2>&1 | head -n 2
  else
    echo "Socat Version   : not found (please install socat)"
  fi
  echo "----------------------------------------"
}
# ---------------------------------
# main()
# ---------------------------------
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
  version)
    version_info
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|version}"
    ;;
esac