#!/bin/bash

# Define colors
red='\e[31m'
yellow='\e[33m'
green='\e[92m'
none='\e[0m'

# Error and warning messages
is_err="${red}错误!${none}"
is_warn="${red}警告!${none}"

err() {
    echo -e "\n$is_err $@\n" && exit 1
}

warn() {
    echo -e "\n$is_warn $@\n"
}

# Check if running as root
[[ $EUID != 0 ]] && err "当前非 ${yellow}ROOT用户.${none}"

# Check if xray is already installed
if type xray &>/dev/null; then
    warn "检测到 xray 已安装，继续执行后续步骤."
else
    # Install xray
    echo "正在安装 xray..."
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)"

    # Check if xray installation is successful
    if ! type xray &>/dev/null; then
        err "xray 安装失败，请检查安装脚本是否正常运行."
    fi
fi

# Generate random vmess port and id
vmess_port=$(shuf -i 10000-65535 -n 1)
vmess_id=$(cat /proc/sys/kernel/random/uuid)

# Prompt user for socks5 proxy information
read -p "请输入 SOCKS5 代理地址: " socks5_address
read -p "请输入 SOCKS5 代理端口: " socks5_port
read -p "请输入 SOCKS5 代理用户名: " socks5_username
read -p "请输入 SOCKS5 代理密码: " socks5_password

# Get local IPv4 address
local_ip=$(curl -s http://api64.ipify.org)

# Check if local_ip is a valid IPv4 address
if [[ ! $local_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    warn "无法获取本机IPv4地址，请手动输入."
    read -p "请输入服务器的IPv4地址: " local_ip
fi

# Generate xray configuration file
cat << EOF > /usr/local/etc/xray/config.json
{
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": $vmess_port,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "$vmess_id"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "/dockerlnmp"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "socks",
            "settings": {
                "servers": [
                    {
                        "address": "$socks5_address",
                        "port": $socks5_port,
                        "users": [
                            {
                                "user": "$socks5_username",
                                "pass": "$socks5_password"
                            }
                        ]
                    }
                ]
            }
        }
    ]
}
EOF

# Restart xray
systemctl restart xray

# Display one-click connection information
echo -e "\n${green}一键连接信息:${none}"
echo -e "${green}vmess://${vmess_id}@${local_ip}:${vmess_port}?encryption=none${none}\n"
