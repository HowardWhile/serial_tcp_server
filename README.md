# Readme

fiibot-serial-bridge



## Quick Start

### 安裝 socat

```shell
sudo apt update
sudo apt install socat yq
```

離線安裝 socat

```shell
sudo apt install ./deb/socat_1.7.4.1-3ubuntu4_amd64.deb
```



### 配置權限

```shell
# 把帳號加入 dialout 群組
sudo usermod -a -G dialout $USER
# 讓變更立即生效
newgrp dialout
```

> 驗證
>
> ```shell
> groups
> ```
>
> 應該會看到 `dialout` 出現



### 配置參數

```shell
```









## Note

```
apt download socat 
```

