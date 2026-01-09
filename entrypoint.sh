#!/bin/bash

# 处理环境变量
# 默认 Header 名为 X-Auth-Key
export AUTH_HEADER_NAME=${AUTH_HEADER_NAME:-"X-Auth-Key"}
# 将 Header 名转换为 Nginx 变量格式 (小写，横杠变下划线)
export AUTH_HEADER_NAME_LOWER=$(echo "$AUTH_HEADER_NAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_')

# 检查是否设置了验证值，如果没有设置，打印警告
if [ -z "$AUTH_HEADER_VALUE" ]; then
    echo "⚠️ 警告: 未设置 AUTH_HEADER_VALUE，访问将被拒绝。"
fi

# 使用 envsubst 替换 Nginx 配置中的变量
# 注意：我们只替换特定的变量，避免破坏 Nginx 自带的变量
envsubst '${AUTH_HEADER_NAME_LOWER} ${AUTH_HEADER_VALUE}' < /opt/antigravity/nginx.conf.template > /etc/nginx/nginx.conf

echo "🚀 启动 Nginx 反向代理 (监听端口 3000)..."
nginx -g "daemon on;"

echo "🚀 启动 Antigravity Server (监听端口 3001)..."
# 设置应用监听 3001 端口
export PORT=3001
# 保持前台运行以便查看日志
exec /opt/antigravity/server
