# Docker 部署

本目录包含 Clash 项目的 Docker 部署相关文件。

## 📁 文件说明

**核心文件**:
- **Dockerfile** - Docker 镜像构建文件
- **docker-compose.yml** - Docker Compose 编排配置

**脚本文件**:
- **docker-start.sh** - ⭐ 快速启动脚本 (推荐使用)
- **docker-entrypoint.sh** - 容器入口脚本

**配置文件**:
- **.dockerignore** - 构建忽略文件
- **.docker.env.example** - 环境变量配置模板

**文档文件**:
- **DOCKER.md** - 详细的 Docker 部署文档
- **README.md** - 本文件

## 🚀 快速开始

### 前置要求

- Docker 已安装
- Docker Compose V2 或 V1

### 使用快速启动脚本 (推荐)

```bash
cd docker
./docker-start.sh
```

脚本会自动:
- 检查 Docker 和 Docker Compose
- 构建镜像
- 启动容器
- 显示访问信息

### 手动启动

```bash
cd docker
docker compose up -d
```

### ⚠️ 重要说明

容器启动后**不会自动启动Clash内核**，需要先添加订阅：

```bash
# 1. 添加订阅（必须）
docker exec -it clash clashsub add <你的订阅链接>

# 2. 使用订阅
docker exec -it clash clashsub use 1

# 3. 启动Clash内核
docker exec -it clash clashon

# 4. 查看状态
docker exec -it clash clashstatus
```

**原因**: Docker环境跳过了交互式订阅配置，容器启动时等待用户手动添加订阅。这是正常行为，不是错误！

## 🔧 配置

复制 `.docker.env.example` 为 `.env` 并修改:

```bash
cp .docker.env.example .env
vim .env
```

主要配置项:
- `CLASH_CONFIG_URL` - 订阅链接
- `KERNEL_NAME` - 内核选择(mihomo/clash)

## 🌐 访问服务

- **Web 控制台**: http://localhost:9091/ui
- **代理端口**: localhost:7891 (HTTP/SOCKS5)
- **DNS 端口**: localhost:1054

> **注意**: 端口已调整为 9091/7891/1054，避免与其他服务冲突。如需修改，请编辑 `docker-compose.yml`。

## 💡 常用命令

```bash
# 查看状态
docker exec clash clashstatus

# 添加订阅
docker exec clash clashsub add <订阅链接>

# 查看日志
docker compose logs -f clash

# 停止容器
docker compose down
```

## 📖 详细文档

完整的部署指南请参考 [DOCKER.md](DOCKER.md)
