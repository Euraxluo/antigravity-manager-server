---
description: 自动从 Antigravity Docker 镜像中提取核心文件
---

1. 确保当前目录下存在 `antigravity-manager.tar.gz`。
2. 赋予脚本执行权限：
   ```bash
   chmod +x extract.sh
   ```
3. 运行提取脚本：
   ```bash
   ./extract.sh antigravity-manager.tar.gz
   ```
4. 脚本会自动：
   - 解析 `manifest.json`。
   - 遍历所有镜像层。
   - 提取 `server` 二进制文件。
   - 提取 `static` 静态资源。
   - 创建 `data/accounts` 目录。
   - 清理临时文件。
5. 提取后的文件将存放在 `Native-Deployment` 文件夹中。
