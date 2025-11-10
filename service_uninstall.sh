#!/bin/bash
# ------------------------------------------------------------------
#  Serial TCP Server - Service Remover
# ------------------------------------------------------------------
#  Version: 0.0.0
#  Author: Howard Cheng
#  Created: 2025-11-10
#  License: MIT
#
#  Description:
#    Stop, disable, and remove the serial-tcp-server service.
#
#  Usage:
#    sudo ./service_remove.sh
#
# ------------------------------------------------------------------

SERVICE_NAME="serial-tcp-server.service"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}"

# ---------------------------------
function remove_service()
# ---------------------------------
{
  echo "Removing ${SERVICE_NAME} ..."

  if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "Stopping service..."
    sudo systemctl stop "$SERVICE_NAME"
  fi

  if systemctl is-enabled --quiet "$SERVICE_NAME"; then
    echo "Disabling service..."
    sudo systemctl disable "$SERVICE_NAME"
  fi

  if [ -f "$SERVICE_PATH" ]; then
    echo "Deleting unit file: $SERVICE_PATH"
    sudo rm -f "$SERVICE_PATH"
  fi

  sudo systemctl daemon-reload
  echo "Service removed successfully."
}

remove_service
