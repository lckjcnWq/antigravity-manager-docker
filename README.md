# Antigravity Tools Docker

将 [Antigravity Tools](https://github.com/lbjlaq/Antigravity-Manager) 桌面应用容器化运行，通过 Web VNC 远程访问。

> ⚠️ **许可证**: [CC BY-NC-SA 4.0](LICENSE) - **禁止商业使用**

## 功能

- 🖥️ Web VNC 远程访问 GUI
- 📋 剪贴板共享
- 💾 配置持久化
- 🔄 自动获取最新版本
- 🏗️ 支持 amd64 / arm64

---

## ⚠️ 安全警告

> **强烈建议不要将 noVNC 端口（6080）暴露到公网！**
>
> noVNC 默认没有密码保护，任何人都可以访问你的桌面。如果需要远程访问，请：
> - 使用 SSH 隧道：`ssh -L 6080:localhost:6080 your-server`
> - 或配置反向代理（如 Nginx）并添加认证
> - 仅将 API 端口（8045）暴露给需要的服务

---

## 部署方式

```bash
# 克隆仓库
git clone https://github.com/lckjcnWq/antigravity-manager-docker.git
cd antigravity-manager-docker

# ARM64 (M1/M2 Mac, AWS Graviton, Oracle ARM)
./build-arm64.sh

# 或 AMD64 (Intel/AMD)
./build-amd64.sh

# 使用本地构建的镜像启动
docker compose -f docker-compose.build.yml up -d
```

# 更新到指定版本
# 把 v3.3.33 标记为 latest
docker tag antigravity-tools:v3.3.33 antigravity-tools:latest

# 强制重建容器
docker compose -f docker-compose.build.yml up -d --force-recreate

> **注意**: 构建脚本使用 `--no-cache` 参数，确保每次构建都会获取最新版本的 Antigravity Tools。

---

## 使用方法

1. **通过 SSH 隧道访问 VNC**（推荐）:
   ```bash
   ssh -L 6080:localhost:6080 your-server
   ```
   然后访问 `http://localhost:6080`

2. **点击 Connect** 进入 VNC 桌面
3. **添加账号**: 在 Antigravity 中进行 OAuth 授权
4. **开启反代**: 在设置中开启 API 反代服务
5. **配置客户端**: 使用 `http://服务器IP:8045` 作为 API 地址

### API 配置示例

```bash
# Claude Code
export ANTHROPIC_API_KEY="sk-antigravity"
export ANTHROPIC_BASE_URL="http://服务器IP:8045"
claude
```

```python
# Python
import openai
client = openai.OpenAI(
    api_key="sk-antigravity",
    base_url="http://服务器IP:8045/v1"
)
```

---

## 端口说明

| 端口 | 用途 | 建议 |
|------|------|------|
| 6080 | noVNC Web 界面 | ⚠️ 仅绑定本地，通过 SSH 隧道访问 |
| 8045 | API 反代服务 | 可暴露给需要的服务 |

---

## 常见问题

### VNC 黑屏怎么办？

1. 等待 30 秒让所有服务启动完成
2. 查看日志：`docker logs antigravity-tools`
3. 检查进程状态：`docker exec -it antigravity-tools supervisorctl status`

### 如何查看当前版本？

```bash
docker exec -it antigravity-tools cat /opt/antigravity/VERSION
```

### 如何更新到最新版本？

```bash
git pull
./build-arm64.sh  # 或 ./build-amd64.sh
docker compose -f docker-compose.build.yml up -d
```

---

## 许可证

本项目继承 [Antigravity Tools](https://github.com/lbjlaq/Antigravity-Manager) 的 **CC BY-NC-SA 4.0** 许可证。

- ✅ 允许：个人使用、修改、分享
- ❌ 禁止：商业使用
- 📝 要求：署名、相同方式共享
