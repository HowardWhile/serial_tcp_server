# Serial TCP Server

A lightweight multi-port **serial-to-TCP bridge** based on `socat`.  
This tool allows multiple serial devices (e.g., `/dev/ttyUSB0`, `/dev/ttyS0`)  
to be exposed as independent TCP servers for remote access.

一個基於 `socat` 的輕量級多埠 **串口轉 TCP 伺服器**，  
可同時將多個串口設備（如 `/dev/ttyUSB0`, `/dev/ttyS0`）  
透過網路提供遠端連線使用。



## Features 

- Supports multiple serial interfaces defined in `config.ini`  

- Each serial port maps to a dedicated TCP port  

  ```ini
  [ports]
  /dev/ttyUSB0=5000
  /dev/ttyUSB1=5001
  ; /dev/ttyS0=5002
  ```



## Quick Start 

### 1. Install `socat` 

**Online installation**

```bash
sudo apt update
sudo apt install socat
```

**Offline installation**

```
sudo apt install ./deb/amd64/*.deb
```

### 2. Set User Permission

Allow the current user to access serial devices such as `/dev/ttyUSB*` or `/dev/ttyS*`.

```shell
# Add the current user to the dialout group
sudo usermod -a -G dialout $USER

# Apply the change immediately (no logout required)
newgrp dialout
```

Verify:

```
groups
```

If you see `dialout` in the output, the permission is correctly set.

### 3. Configure Ports 

Edit the `config.ini` file to define which serial devices will be bridged to which TCP ports.

```ini
[ports]
/dev/ttyUSB0=5000
/dev/ttyUSB1=5001
/dev/ttyS0=5002
```

Each line defines one mapping:

```
<serial_device>=<tcp_port>
```

Example: `/dev/ttyUSB0` will open a TCP server on port `5000`.

### 4. Launch the Server 

Make the script executable.

```shell
chmod +x launch.sh
```

Usage:

```shell

./launch.sh start     # Start all configured serial bridges
./launch.sh stop      # Stop all running socat processes
./launch.sh restart   # Restart all bridges
./launch.sh status    # Display current running bridges
./launch.sh version   # Display current running bridges
```



## Systemd Service Integration

The Serial TCP Server can also be installed as a **systemd service**,
 allowing it to automatically start at boot and be managed with `systemctl`.

Serial TCP Server 也可以安裝為 **systemd 系統服務**，
 使其在開機時自動啟動，並能透過 `systemctl` 進行啟停與狀態管理。

### Install the Service

Make sure both scripts are executable, then install the service:

```shell
chmod +x service_install.sh service_remove.sh
sudo ./service_install.sh
```

This will:

- Create `/etc/systemd/system/serial-tcp-server.service`
- Enable it to start at boot
- Launch the service immediately

**Manual Control**

You can also manage it directly with `systemctl`:

```shell
sudo systemctl start serial-tcp-server.service
sudo systemctl stop serial-tcp-server.service
sudo systemctl restart serial-tcp-server.service
sudo systemctl status serial-tcp-server.service # Check service status
```

> **Remove the Service**
>
> To uninstall or disable the service:
>
> ```
> sudo ./service_remove.sh
> ```
>
> This will stop and disable the service, then delete its definition from `/etc/systemd/system/`.



## Note

```
apt download socat 
```

