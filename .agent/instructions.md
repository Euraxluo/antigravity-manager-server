# Antigravity Manager Server 维护指南 (面向 AI 代理)

## 项目背景
本项目是从 `lbjlaq/Antigravity-Manager` 的 Docker 镜像中提取出的原生 Linux (amd64) 运行环境。主要用于在不支持 Docker 的 VPS 上部署。

## 核心组件
- `server`: Rust 编写的 ELF 64-bit 二进制文件。
- `static/`: 前端 React 编译后的静态资源。
- `data/`: 运行数据目录（需手动创建 `data/accounts`）。
- `extract.sh`: 自动化提取脚本，用于从新的 Docker 镜像中更新文件。

## 关键维护步骤

### 1. 更新程序
当上游 Docker 镜像更新时：
1. 下载新的 `antigravity-manager.tar.gz`。
2. 运行 `./extract.sh antigravity-manager.tar.gz`。
3. 脚本会自动更新 `Native-Deployment` 文件夹中的内容。

### 2. 部署与维护
- **硬编码路径修复**：程序内部硬编码了 `/app/static`。在任何新环境中部署，必须执行 `sudo ln -s /opt/antigravity /app`。
- **服务重启**：在非 systemd 环境（如 Docker 容器内）下，使用 `./restart.sh` 安全重启服务，它会处理进程查找、停止和后台重新启动。
- **依赖项**：确保系统安装了 `libssl3` 和 `ca-certificates`。
- **环境变量**：
    - `ANTIGRAVITY_DATA_DIR`: 指向数据目录。
    - `PROXY_AUTO_START`: 建议设为 `true`。
    - `ALLOW_LAN_ACCESS`: 建议设为 `true`。

### 3. 故障排除
- 如果前端无法加载，检查 `/app` 软链接是否正确指向了安装目录。
- 如果代理无法启动，检查 `data/accounts` 目录是否存在且有读写权限。
