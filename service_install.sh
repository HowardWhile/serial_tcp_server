#!/bin/bash
# ------------------------------------------------------------------
#  Serial TCP Server - Service Installer
# ------------------------------------------------------------------
#  Version: 0.3.0
#  Author: Howard Cheng
#  Created: 2025-12-15
#  License: MIT
#
#  Description:
#    Install, enable, and start the serial-tcp-server as a systemd service.
#    The service automatically starts at boot and manages serial-to-TCP bridges.
#
#  Usage:
#    sudo ./service_install.sh
#
# ------------------------------------------------------------------

SERVICE_NAME="serial-tcp-server.service"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}"
EXEC_PATH="$(realpath ./launch.sh)"

# ---------------------------------
function install_service()
# ---------------------------------
{
  echo "Installing ${SERVICE_NAME} ..."

  if [ ! -f "$EXEC_PATH" ]; then
    echo "Error: launch.sh not found at $EXEC_PATH"
    exit 1
  fi

  sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Serial TCP Server
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash ${EXEC_PATH} start
ExecStop=/bin/bash ${EXEC_PATH} stop
RemainAfterExit=yes
User=${USER}
WorkingDirectory=$(pwd)
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable "$SERVICE_NAME"
  sudo systemctl start "$SERVICE_NAME"

  echo "Service installed and started successfully."
  echo "Check status with: sudo systemctl status ${SERVICE_NAME}"
}

install_service