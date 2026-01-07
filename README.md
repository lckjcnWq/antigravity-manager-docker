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

## 部署方式

### 方式一：使用 Docker Hub 镜像（推荐）

```bash
# 拉取镜像（自动选择架构）
docker pull guguchen/antigravity-tools:latest

# 运行
docker run -d \
  --name antigravity-tools \
  -p 6080:6080 \
  -p 8045:8045 \
  -v antigravity-data:/root/.antigravity_tools \
  --restart unless-stopped \
  guguchen/antigravity-tools:latest
```

### 方式二：Docker Compose 部署

```bash
# 下载 docker-compose.yml
curl -O https://raw.githubusercontent.com/guguchen/antigravity-manager-docker/main/docker-compose.yml

# 启动
docker compose up -d
```

### 方式三：自行构建

```bash
# 克隆仓库
git clone https://github.com/guguchen/antigravity-manager-docker.git
cd antigravity-manager-docker

# ARM64 (M1/M2 Mac, AWS Graviton)
./build-arm64.sh

# 或 AMD64 (Intel/AMD)
./build-amd64.sh

# 启动
docker compose up -d
```

---

## 使用方法

1. **访问 Web VNC**: 打开浏览器访问 `http://服务器IP:6080`
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

| 端口 | 用途 |
|------|------|
| 6080 | noVNC Web 界面 |
| 8045 | API 反代服务 |

## 可用镜像标签

| 标签 | 说明 |
|------|------|
| `latest` | 最新版本 |
| `3.3.15` | 指定版本（示例） |

```bash
# 使用指定版本
docker pull guguchen/antigravity-tools:3.3.15
```

---

## 许可证

本项目继承 [Antigravity Tools](https://github.com/lbjlaq/Antigravity-Manager) 的 **CC BY-NC-SA 4.0** 许可证。

- ✅ 允许：个人使用、修改、分享
- ❌ 禁止：商业使用
- 📝 要求：署名、相同方式共享
