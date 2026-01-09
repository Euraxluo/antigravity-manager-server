#!/bin/bash
# Antigravity Manager Docker 提取脚本
# 用法: ./extract.sh <docker-image-tarball>

TARBALL=$1
TARGET_DIR="./Native-Deployment"

if [ -z "$TARBALL" ]; then
    echo "用法: $0 <docker-image-tarball>"
    exit 1
fi

if [ ! -f "$TARBALL" ]; then
    echo "错误: 找不到文件 $TARBALL"
    exit 1
fi

echo "🚀 开始提取 Docker 镜像..."
mkdir -p .tmp_extract
tar -xf "$TARBALL" -C .tmp_extract

echo "🔍 正在解析镜像层..."
# 使用 Python 解析 manifest.json 以获取层列表
LAYERS=$(python3 -c "import json; print('\n'.join(json.load(open('.tmp_extract/manifest.json'))[0]['Layers']))")

mkdir -p "$TARGET_DIR"

for LAYER in $LAYERS; do
    LAYER_FILE=".tmp_extract/$LAYER"
    echo "📦 检查层: $LAYER"
    
    # 检查并提取 server 二进制文件
    if tar -tf "$LAYER_FILE" | grep -q "app/server$"; then
        echo "✨ 发现服务端程序，正在提取..."
        tar -xf "$LAYER_FILE" -C "$TARGET_DIR" --strip-components=1 app/server
    fi
    
    # 检查并提取 static 静态资源
    if tar -tf "$LAYER_FILE" | grep -q "app/static/"; then
        echo "✨ 发现静态资源，正在提取..."
        tar -xf "$LAYER_FILE" -C "$TARGET_DIR" --strip-components=1 app/static
    fi
done

# 创建必要的数据目录
mkdir -p "$TARGET_DIR/data/accounts"

echo "🧹 清理临时文件..."
rm -rf .tmp_extract

echo "✅ 提取完成！文件已存放在: $TARGET_DIR"
ls -lh "$TARGET_DIR"
