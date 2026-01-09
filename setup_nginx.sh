#!/bin/bash
# Antigravity Manager - Nginx Docker 环境一键安装启动脚本
# 用法: 在 pull 仓库后运行 ./setup_nginx.sh

echo "🚀 开始配置 Nginx Docker 环境..."

# 1. 安装基础依赖
echo "📦 正在安装依赖 (libssl, ca-certificates, curl)..."
apt-get update && apt-get install -y ca-certificates libssl3 curl

# 2. 准备运行目录
echo "📂 正在解压程序包..."
INSTALL_DIR="/opt/antigravity"
mkdir -p "$INSTALL_DIR"
tar -xzf antigravity-native.tar.gz -C "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/data/accounts"

# 3. 修复硬编码路径 (创建软链接)
echo "🔗 正在修复路径依赖 (/app -> $INSTALL_DIR)..."
if [ -d "/app" ] && [ ! -L "/app" ]; then
    echo "⚠️ 警告: /app 目录已存在且不是软链接，正在尝试备份..."
    mv /app /app_backup_$(date +%s)
fi
ln -snf "$INSTALL_DIR" /app

# 4. 设置执行权限
chmod +x "$INSTALL_DIR/server"

# 5. 启动程序
echo "🌟 正在启动 Antigravity Manager..."
export ANTIGRAVITY_DATA_DIR="$INSTALL_DIR/data"
export PROXY_AUTO_START=true
export ALLOW_LAN_ACCESS=true
export RUST_LOG=info

# 提示：在 Docker 中通常需要前台运行，或者使用 nohup
echo "------------------------------------------------"
echo "✅ 安装完成！程序将在后台运行。"
echo "🔗 访问地址: http://localhost:3000"
echo "------------------------------------------------"

nohup "$INSTALL_DIR/server" > "$INSTALL_DIR/server.log" 2>&1 &

echo "📝 日志输出在: $INSTALL_DIR/server.log"
tail -f "$INSTALL_DIR/server.log"
