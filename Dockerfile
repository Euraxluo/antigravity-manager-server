# 使用 Debian Bookworm Slim 作为基础镜像
FROM debian:bookworm-slim

# 安装必要依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    curl \
    nginx \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /opt/antigravity

# 复制程序文件
COPY server .
COPY static ./static
COPY nginx.conf.template .
COPY entrypoint.sh .

# 补丁：将硬编码的 0.0.0.0:3000 修改为 0.0.0.0:3001
RUN sed -i 's/0.0.0.0:3000/0.0.0.0:3001/g' server

RUN mkdir -p data/accounts && chmod +x entrypoint.sh

# 修复硬编码路径：程序默认从 /app/static 读取静态资源
RUN ln -s /opt/antigravity /app

# 设置环境变量
ENV ANTIGRAVITY_DATA_DIR=/opt/antigravity/data
ENV PROXY_AUTO_START=true
ENV ALLOW_LAN_ACCESS=true
ENV RUST_LOG=info

# 暴露端口 (Nginx 监听 3000)
EXPOSE 3000 8045

# 启动命令
ENTRYPOINT ["./entrypoint.sh"]
