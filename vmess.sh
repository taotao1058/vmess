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

# Check the package manager (yum or apt-get)
cmd=$(type -P apt-get || type -P yum)
[[ ! $cmd ]] && err "此脚本仅支持 ${yellow}(Ubuntu or Debian or CentOS)${none}."

# Check for systemd
[[ ! $(type -P systemctl) ]] && {
    err "此系统缺少 ${yellow}(systemctl)${none}, 请尝试执行:${yellow} ${cmd} update -y;${cmd} install systemd -y ${none}来修复此错误."
}

# Check if wget is installed
is_wget=$(type -P wget)
[[ ! $is_wget ]] && err "请安装 wget."

# Architecture check (x64 or arm64)
case $(uname -m) in
    amd64 | x86_64)
        is_core_arch="64"
        ;;
    *aarch64* | *armv8*)
        is_core_arch="arm64-v8a"
        ;;
    *)
        err "此脚本仅支持 64 位系统..."
        ;;
esac

# Variables
is_core=v2ray
is_core_name=V2Ray
is_core_dir=/etc/$is_core
is_core_bin=$is_core_dir/bin/$is_core
is_core_repo=v2fly/$is_core-core
is_conf_dir=$is_core_dir/conf
is_log_dir=/var/log/$is_core
is_sh_bin=/usr/local/bin/$is_core
is_sh_dir=$is_core_dir/sh
is_sh_repo=233boy/$is_core
is_pkg="wget unzip"
is_config_json=$is_conf_dir/config.json

# Temporary directory
tmpdir=$(mktemp -u)
[[ ! $tmpdir ]] && tmpdir=/tmp/tmp-$RANDOM

# Function to download file using wget
_wget() {
    [[ $proxy ]] && export https_proxy=$proxy
    wget --no-check-certificate $*
}

# Function to print messages
msg() {
    case $1 in
        warn)
            local color=$yellow
            ;;
        err)
            local color=$red
            ;;
        ok)
            local color=$green
            ;;
    esac
    echo -e "${color}$(date +'%T')${none}) ${2}"
}

# Install dependent packages
install_pkg() {
    cmd_not_found=
    for i in $*; do
        [[ ! $(type -P $i) ]] && cmd_not_found="$cmd_not_found,$i"
    done
    if [[ $cmd_not_found ]]; then
        pkg=$(echo $cmd_not_found | sed 's/,/ /g')
        msg warn "安装依赖包 >${pkg}"
        $cmd install -y $pkg &>/dev/null
        if [[ $? != 0 ]]; then
            [[ $cmd =~ yum ]] && yum install epel-release -y &>/dev/null
            $cmd update -y &>/dev/null
            $cmd install -y $pkg &>/dev/null
            [[ $? == 0 ]] && >$tmpdir/is_pkg_ok
        else
            >$tmpdir/is_pkg_ok
        fi
    else
        >$tmpdir/is_pkg_ok
    fi
}

# Function to download V2Ray core file
download_core() {
    link=https://github.com/${is_core_repo}/releases/latest/download/${is_core}-linux-${is_core_arch}.zip
    [[ $is_core_ver ]] && link="https://github.com/${is_core_repo}/releases/download/${is_core_ver}/${is_core}-linux-${is_core_arch}.zip"
    msg warn "下载 ${is_core_name} > ${link}"
    if _wget -t 3 -q -c $link -O $tmpdir/v2ray.zip; then
        unzip -qo $tmpdir/v2ray.zip -d $is_core_dir/bin
    else
        msg err "下载 ${is_core_name} 失败"
        exit 1
    fi
}

# Function to generate V2Ray configuration file
generate_config() {
    msg warn "生成配置文件..."
    mkdir -p $is_conf_dir
    cat << EOF > $is_config_json
{
    "inbounds": [
        {
            "port": 10000,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "b831381d-6324-4d53-ad4f-8cda48b30811",
                        "alterId": 64
                    }
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ]
}
EOF
}

# Function to print one-click connection information
print_one_click_info() {
    local vmess_link="vmess://$(cat $is_config_json | base64 -w 0)"
    echo -e "\n${green}一键连接信息:${none}"
    echo -e "${green}${vmess_link}${none}\n"
}

# Main function
main() {
    # Check if V2Ray is already installed
    [[ -f $is_core_bin && -d $is_core_dir/bin && -d $is_sh_dir && -d $is_conf_dir ]] && {
        err "检测到 ${is_core_name} 已安装."
    }

    # Check for root privilege
    [[ $EUID != 0 ]] && err "当前非 ${yellow}ROOT用户.${none}"

    # Check for systemd
    [[ ! $(type -P systemctl) ]] && {
        err "此系统缺少 ${yellow}(systemctl)${none}, 请尝试执行:${yellow} ${cmd} update -y;${cmd} install systemd -y ${none}来修复此错误."
    }

    # Check if wget is installed
    is_wget=$(type -P wget)
    [[ ! $is_wget ]] && err "请安装 wget."

    # Architecture check (x64 or arm64)
    case $(uname -m) in
        amd64 | x86_64)
            is_core_arch="64"
            ;;
        *aarch64* | *armv8*)
            is_core_arch="arm64-v8a"
            ;;
        *)
            err "此脚本仅支持 64 位系统..."
            ;;
    esac

    # Create temporary directory
    mkdir -p $tmpdir

    # Install dependent packages
    install_pkg $is_pkg

    # Download V2Ray core
    download_core

    # Generate V2Ray configuration file
    generate_config

    # Create core command
    ln -sf $is_core_dir/sh/$is_core.sh $is_sh_bin

    # Create log directory
    mkdir -p $is_log_dir

    # Print a success message
    msg ok "安装完成!"

    # Print one-click connection information
    print_one_click_info
}

# Start
main
