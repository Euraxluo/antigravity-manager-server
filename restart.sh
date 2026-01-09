#!/bin/bash
# Antigravity Manager - 服务重启脚本
# 适用于在 Nginx Docker 或原生 Linux 环境中运行的情况

INSTALL_DIR="/opt/antigravity"
SERVER_BIN="$INSTALL_DIR/server"
LOG_FILE="$INSTALL_DIR/server.log"

echo "🔄 正在尝试重启 Antigravity Manager 服务..."

# 1. 查找并停止现有进程
PID=$(pgrep -f "$SERVER_BIN")

if [ -n "$PID" ]; then
    echo "🛑 发现正在运行的进程 (PID: $PID)，正在停止..."
    kill "$PID"
    sleep 2
    
    # 强制检查是否停止
    if pgrep -f "$SERVER_BIN" > /dev/null; then
        echo "⚠️ 进程未响应，正在强制停止..."
        pkill -9 -f "$SERVER_BIN"
    fi
else
    echo "ℹ️ 未发现正在运行的服务进程。"
fi

# 2. 启动服务
echo "🚀 正在启动服务..."
export ANTIGRAVITY_DATA_DIR="$INSTALL_DIR/data"
export PROXY_AUTO_START=true
export ALLOW_LAN_ACCESS=true
export RUST_LOG=info

nohup "$SERVER_BIN" > "$LOG_FILE" 2>&1 &

# 3. 验证
sleep 1
NEW_PID=$(pgrep -f "$SERVER_BIN")
if [ -n "$NEW_PID" ]; then
    echo "✅ 服务已成功重启 (新 PID: $NEW_PID)"
    echo "📝 日志输出在: $LOG_FILE"
else
    echo "❌ 服务启动失败，请检查日志: $LOG_FILE"
    exit 1
fi
