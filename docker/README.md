# Docker 部署

本目录包含 Clash 项目的 Docker 部署相关文件。

## 🔧 前置准备

### 安装 Docker

如果你的服务器还没有安装 Docker,请先查看 **[Docker 安装指南](DOCKER_INSTALL.md)**。

该指南包含:
- ✅ Ubuntu/Debian/CentOS/RHEL 系统安装步骤
- ✅ 安装验证方法
- ✅ 常见问题解决方案
- ✅ 国内用户镜像加速配置

## 🌐 获取项目代码

**如果你还没有项目代码**,可以先克隆仓库。本项目提供了多种克隆方式:

**方式一: 使用 Gitee 镜像 (推荐国内用户)**

```bash
git clone --branch master --depth 1 https://gitee.com/honlnk/clash-for-linux-install-docker.git
cd clash-for-linux-install-docker/docker
```

**方式二: 使用 GitHub 加速代理**

```bash
git clone --branch master --depth 1 https://gh-proxy.org/https://github.com/nelvko/clash-for-linux-install.git
cd clash-for-linux-install/docker
```

**方式三: 直接克隆 GitHub**

```bash
git clone --branch master --depth 1 https://github.com/nelvko/clash-for-linux-install.git
cd clash-for-linux-install/docker
```

## 📁 文件说明

- **Dockerfile** - Docker 镜像构建文件
- **docker-compose.yml** - Docker Compose 编排配置
- **docker-entrypoint.sh** - 容器入口脚本
- **docker-start.sh** - 快速启动脚本 (自动兼容 V1/V2)
- **.dockerignore** - 构建忽略文件
- **.docker.env.example** - 环境变量配置模板
- **DOCKER.md** - 详细的 Docker 部署文档
- **DOCKER_INSTALL.md** - Docker 安装指南
- **DOCKER_COMPOSE_VERSION.md** - Docker Compose 版本说明

## 🚀 快速开始

> 📝 **Docker Compose 版本说明**: 本项目使用 Docker Compose V2 语法 (`docker compose`)
> - 如果你看到 `Command 'docker-compose' not found`,说明你使用的是 V2 (推荐)
> - 命令对照: `docker-compose` (V1) → `docker compose` (V2)
> - 详细说明请参考: [Docker Compose 版本说明](DOCKER_COMPOSE_VERSION.md)

### 方式一: 使用快速启动脚本 (⭐ 最推荐)

**为什么推荐这种方式?**
- ✅ **自动检测并使用 sudo** - 无需手动添加 sudo
- ✅ **自动兼容 V1/V2** - 无论哪个版本都能正常运行
- ✅ **一键完成所有操作** - 检查环境 → 构建镜像 → 启动容器
- ✅ **友好的错误提示** - 遇到问题会给出解决方案
- ✅ **适合新手** - 不需要记住复杂的 docker 命令

```bash
# 在 docker/ 目录下执行
./docker-start.sh
```

**脚本会自动处理**:
1. 检查 Docker 是否安装
2. 检查 Docker Compose 版本 (V1/V2)
3. 检测权限问题并自动使用 sudo
4. 构建镜像
5. 启动容器
6. 显示访问信息和管理命令

**示例输出**:
```
😼 Clash Docker 快速启动脚本

[INFO] Docker 已安装: Docker version 27.0.1
[WARN] 当前用户没有 docker 权限,将自动使用 sudo
[INFO] Docker Compose V2 已就绪: v5.0.1
[INFO] 开始构建 Docker 镜像...
...
[INFO] 容器启动成功

==========================================
           😼 Clash 已启动
==========================================

Web 控制台: http://localhost:9090/ui
代理端口: 7890 (HTTP/SOCKS5)
DNS 端口: 1053

常用命令:
  查看日志: sudo docker compose logs -f clash
  查看状态: sudo docker exec clash clashstatus
  添加订阅: sudo docker exec clash clashsub add <url>
==========================================
```

### 方式二: 手动使用 docker compose

如果你更喜欢手动控制,可以直接使用 docker compose 命令:

> **执行目录说明**:
> - 快速启动和 docker-compose 命令在 `docker/` 目录下执行
> - 手动构建命令在 `项目根目录` 下执行

> **⚠️ 注意**: 如果遇到权限错误,需要在命令前加 `sudo`

```bash
# 在 docker/ 目录下执行
# 启动
sudo docker compose up -d

# 查看日志
sudo docker compose logs -f clash

# 停止
sudo docker compose down
```

### 方式三: 手动构建

```bash
# 在项目根目录下执行
# 构建镜像
docker build -f docker/Dockerfile -t clash-for-linux:latest .

# 运行容器
docker run -d \
  --name clash \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -p 7890:7890 \
  -p 9090:9090 \
  clash-for-linux:latest
```

## 📖 详细文档

完整的部署指南请参考 [DOCKER.md](DOCKER.md)

## 🔧 配置

> **执行目录**: `docker/`

复制 `.docker.env.example` 为 `.env` 并修改配置:

```bash
# 在 docker/ 目录下执行
cp .docker.env.example .env
vim .env
```

主要配置项:
- `CLASH_CONFIG_URL` - 订阅链接
- `KERNEL_NAME` - 内核选择(mihomo/clash)

## 🌐 访问服务

- **Web 控制台**: http://localhost:9090/ui
- **代理端口**: localhost:7890
- **DNS 端口**: localhost:1053

## 💡 常用命令

```bash
# 查看状态
docker exec clash clashstatus

# 添加订阅
docker exec -it clash clashsub add <订阅链接>

# 查看日志
docker logs -f clash

# 进入容器
docker exec -it clash bash
```
