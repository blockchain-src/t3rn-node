#!/bin/bash

# 切换到节点运行目录
cd ./executor/executor/bin || { echo "节点目录未找到！"; exit 1; }

# 配置环境变量
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_ORDERS=true
export EXECUTOR_PROCESS_CLAIMS=true

# 从 .env 文件加载私钥
if [ -f $HOME/.env ]; then
    source $HOME/.env
else
    echo "未找到 .env 文件，确保您已设置 PRIVATE_KEY_LOCAL。"
    exit 1
fi

export ENABLED_NETWORKS='base-sepolia,arbitrum-sepolia,optimism-sepolia,l1rn'

# 启动节点
screen -S t3rn -d -m bash -c './executor'
echo "节点已启动！使用 'screen -r t3rn' 查看日志。"
