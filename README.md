# Antigravity Manager 原生部署工作空间

这个文件夹包含了将 Antigravity Manager 部署到不支持 Docker 的 VPS 所需的所有核心文件。

> [!IMPORTANT]
> **官方 Docker 镜像**：如果您可以使用 Docker，请直接拉取：
> ```bash
> docker pull euraxluo/antigravity-manager:latest
> ```

## 文件说明
- `antigravity-native.tar.gz`: 核心程序包（包含二进制文件和前端静态资源）。
- `antigravity.service`: Systemd 服务配置文件。

## 快速部署步骤

1. **安装依赖** (在 VPS 上):
   ```bash
   sudo apt-get update && sudo apt-get install -y ca-certificates libssl3 curl
   ```

2. **准备目录并上传**:
   ```bash
   mkdir -p /opt/antigravity
   # 将 antigravity-native.tar.gz 上传到该目录并解压
   tar -xzf antigravity-native.tar.gz -C /opt/antigravity
   ```

3. **修复路径依赖**:
   ```bash
   # 程序硬编码了 /app/static 路径，需要创建软链接
   sudo ln -s /opt/antigravity /app
   ```

## 🐳 Nginx Docker 环境快速启动

如果您在 Nginx Docker 镜像（或其他 Debian 系镜像）中运行，可以使用一键脚本：

1. **Clone 仓库**:
   ```bash
   git clone git@github.com:Euraxluo/antigravity-manager-server.git
   cd antigravity-manager-server
   ```

2. **运行安装脚本**:
   ```bash
   chmod +x setup_nginx.sh
   ./setup_nginx.sh
   ```
   该脚本会自动安装 `libssl3`、解压程序、创建 `/app` 软链接并启动服务。

4. **配置 Systemd**:
   - 将 `antigravity.service` 上传到 `/etc/systemd/system/`。
   - 运行以下命令启动服务：
     ```bash
     sudo systemctl daemon-reload
     sudo systemctl enable antigravity
     sudo systemctl start antigravity
     ```

5. **验证**:
   访问 `http://<VPS_IP>:3000` 或运行 `curl http://localhost:3000/api/proxy/status`。

---
详细方案请参考项目根目录下的 `implementation_plan.md`。

## 附录：如何从 Docker 镜像中自动提取？

如果您未来需要更新版本，可以使用我为您准备的自动化脚本 `extract.sh`：

### 自动化提取步骤
1.  确保 `antigravity-manager.tar.gz` 位于项目根目录。
2.  运行脚本：
    ```bash
    chmod +x extract.sh
    ./extract.sh antigravity-manager.tar.gz
    ```
3.  脚本会自动解析镜像层并提取 `server` 和 `static` 文件到 `Native-Deployment` 文件夹。

### 脚本逻辑说明 (手动参考)
如果您想了解脚本做了什么，或者需要手动操作：
1.  **解压镜像**：`tar -xf <file>.tar.gz`。
2.  **解析层**：读取 `manifest.json` 获取 `Layers` 列表。
3.  **遍历层**：在每个层（`.tar` 文件）中搜索 `app/server` 和 `app/static`。
4.  **提取文件**：使用 `tar -xf <layer>.tar --strip-components=1 app/server` 进行提取。
