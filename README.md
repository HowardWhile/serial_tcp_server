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
sudo apt install ./deb/socat_1.7.4.1-3ubuntu4_amd64.deb
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





## Note

```
apt download socat 
```

