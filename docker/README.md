# Docker 部署

本目录包含 Clash 项目的 Docker 部署相关文件。

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
- **docker-start.sh** - 快速启动脚本
- **.dockerignore** - 构建忽略文件
- **.docker.env.example** - 环境变量配置模板
- **DOCKER.md** - 详细的 Docker 部署文档

## 🚀 快速开始

> **执行目录说明**:
> - 快速启动和 docker-compose 命令在 `docker/` 目录下执行
> - 手动构建命令在 `项目根目录` 下执行

### 使用快速启动脚本(推荐)

```bash
# 在 docker/ 目录下执行
./docker-start.sh
```

### 使用 docker-compose

```bash
# 在 docker/ 目录下执行
# 启动
docker-compose up -d

# 查看日志
docker-compose logs -f clash

# 停止
docker-compose down
```

### 手动构建

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
