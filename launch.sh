#!/bin/bash
# ------------------------------------------------------------------
#  Serial TCP Server - Launch Script
# ------------------------------------------------------------------
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
# ------------------------------------------------------------------

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
  echo "Starting Serial TCP Server..."
  
  for dev in "${!PORTS[@]}"; do
    port_broker=${PORTS[$dev]}                   
    sock_path="/tmp/serial_bridge_${port_broker}.sock"

    if [ ! -e "$dev" ]; then
      echo "Warning: $dev not found, skipping."
      continue
    fi

    # 清除舊 socket
    [ -S "$sock_path" ] && rm -f "$sock_path"

    echo
    echo "Launching bridge ${dev} TCP:${port_broker}"

    # [serial bridge] serial → UNIX socket
    if ! pgrep -f "socat.*UNIX-LISTEN:${sock_path}.*${dev}" >/dev/null; then
      echo "  [serial bridge] ${dev} → ${sock_path} ..."
      socat UNIX-LISTEN:${sock_path},reuseaddr FILE:${dev},b${BAUD},raw,echo=0 &
    else
      echo "  [serial bridge] already running."
    fi

    # [broker] ncat TCP server
    if ! pgrep -f "ncat.*--listen ${port_broker}" >/dev/null; then
      echo "  [broker] on TCP:${port_broker} ..."
      ncat --broker --listen ${port_broker} &
    else
      echo "  [broker] already running."
    fi

    # [relay] UNIX socket → TCP broker
    if ! pgrep -f "socat.*UNIX-CONNECT:${sock_path}.*TCP:127.0.0.1:${port_broker}" >/dev/null; then
      echo "  [relay] ${sock_path} → TCP:${port_broker} ..."
      until [ -S "$sock_path" ]; do sleep 0.1; done
      while ! (echo > /dev/tcp/127.0.0.1/$port_broker) >/dev/null 2>&1; do sleep 0.1; done
      socat UNIX-CONNECT:${sock_path} TCP:127.0.0.1:${port_broker} &
    else
      echo "  [relay] already running."
    fi

  done

  echo
  echo " All bridges launched successfully."
}
# ---------------------------------
function stop_all()
# ---------------------------------
{
  echo "Stopping Serial TCP Server..."
  echo

  # 取得所有 socat / ncat 進程
  socat_pids=$(pgrep -a socat | grep -E "UNIX|TCP" | awk '{print $1}')
  ncat_pids=$(pgrep -a ncat | grep -- "--broker" | awk '{print $1}')

  # 殺掉 socat
  if [ -n "$socat_pids" ]; then
    echo "Stopping socat bridges and relays..."
    for pid in $socat_pids; do
      echo "  [socat] killed PID $pid"
      kill "$pid" 2>/dev/null
    done
  else
    echo "No socat processes found."
  fi
  echo

  # 殺掉 ncat
  if [ -n "$ncat_pids" ]; then
    echo "Stopping ncat brokers..."
    for pid in $ncat_pids; do
      echo "  [ncat] killed PID $pid"
      kill "$pid" 2>/dev/null
    done
  else
    echo "No ncat broker processes found."
  fi
  echo

  # 清理 UNIX socket
  echo "Cleaning up UNIX sockets..."
  find /tmp -maxdepth 1 -type s -name "serial_bridge_*.sock" -delete

  echo
  echo "All Serial TCP Server processes stopped."
}
# ---------------------------------
function status_all()
# ---------------------------------
{
  echo "----------------------------------------"
  echo "Serial TCP Server - Current Status"
  echo "----------------------------------------"

  # 取得 socat 與 ncat 進程清單
  local socat_list ncat_list
  socat_list=$(pgrep -a socat)
  ncat_list=$(pgrep -a ncat | grep -- "--broker")

  if [ -z "$socat_list" ] && [ -z "$ncat_list" ]; then
    echo "No active bridges or brokers running."
    echo
    return
  fi

  # 顯示 Raw Command Lines 
  echo
  echo "[Raw Processes]"
  echo "$socat_list"
  echo "$ncat_list"
  echo

  # 解析 socat UNIX-LISTEN（serial bridge）
  echo "[Serial Bridges (UNIX-LISTEN)]"
  echo "$socat_list" | grep "UNIX-LISTEN" | while read -r line; do
    sock=$(echo "$line" | sed -nE 's/.*UNIX-LISTEN:([^, ]+).*/\1/p')
    dev=$(echo "$line" | sed -nE 's/.*FILE:([^, ]+).*/\1/p')
    if [ -n "$sock" ] && [ -n "$dev" ]; then
      printf "  %s → %-25s\n" "$dev" "$sock" 
    fi
  done
  echo

  # 解析 socat UNIX-CONNECT(relay)
  echo "[Relays (UNIX-CONNECT → TCP)]"
  echo "$socat_list" | grep "UNIX-CONNECT" | while read -r line; do
    sock=$(echo "$line" | sed -nE 's/.*UNIX-CONNECT:([^, ]+).*/\1/p')
    port=$(echo "$line" | sed -nE 's/.*TCP:127.0.0.1:([0-9]+).*/\1/p')
    if [ -n "$sock" ] && [ -n "$port" ]; then
      printf "  %-25s → TCP:%s\n" "$sock" "$port"
    fi
  done
  echo

  # 解析 ncat broker 
  echo "[TCP Brokers]"
  echo "$ncat_list" | while read -r line; do
    port=$(echo "$line" | sed -nE 's/.*--listen[[:space:]]+([0-9]+).*/\1/p')
    pid=$(echo "$line" | awk '{print $1}')
    if [ -n "$port" ]; then
      printf "  TCP:%-6s (PID %s)\n" "$port" "$pid"
    fi
  done
  echo

  echo "Status check completed."
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