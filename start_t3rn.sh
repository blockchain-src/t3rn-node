#!/bin/bash

# 确保脚本在正确的目录下运行
cd executor/executor/bin || { echo "节点目录未找到!"; exit 1; }

# 配置环境变量
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_ORDERS=true
export EXECUTOR_PROCESS_CLAIMS=true

# 从 .env 文件加载私钥
if [ -f "$HOME/.env" ]; then
    source "$HOME/.env"
else
    echo "未找到 .env 文件，确保您已设置 PRIVATE_KEY_LOCAL。"
    exit 1
fi

export ENABLED_NETWORKS='base-sepolia,arbitrum-sepolia,optimism-sepolia,l1rn'

# 确保 executor 可执行文件存在
if [ ! -f "./executor/executor/bin/executor" ]; then
    echo "未找到可执行文件！请检查路径。"
    exit 1
fi

# 启动节点（如果没有正在运行的会话，则创建一个新的）
screen -S t3rn -d -m bash -c './executor/executor/bin/executor'

# 确认 screen 会话是否已创建
if screen -ls | grep -q "t3rn"; then
    echo "节点已启动！使用 'screen -r t3rn' 查看日志。"
else
    echo "节点启动失败！"
    exit 1
fi
