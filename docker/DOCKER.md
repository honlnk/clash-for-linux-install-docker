# Clash Docker 部署指南

本文档介绍如何使用 Docker 部署 clash-for-linux-install 项目。

## 前置准备

### 安装 Docker

如果你的服务器还没有安装 Docker,推荐使用 **tech-shrimp/docker_installer** 项目。

#### 方式一：一键安装（推荐国内用户）

**项目地址**: https://github.com/tech-shrimp/docker_installer
**作者**: 技术爬爬虾（Bilibili 知名科技 UP 主）

该项目专门解决国内网络环境下无法安装 Docker 的问题，使用 Docker 官方安装包，每天自动同步最新版本，安全可靠。

**一键安装命令**:

```bash
# GitHub 链接
sudo curl -fsSL https://github.com/tech-shrimp/docker_installer/releases/download/latest/linux.sh | bash -s docker --mirror Aliyun

# Gitee 备用链接（国内推荐）
sudo curl -fsSL https://gitee.com/tech-shrimp/docker_installer/releases/download/latest/linux.sh | bash -s docker --mirror Aliyun
```

**启动 Docker 服务**:

```bash
sudo service docker start
```

**配置镜像加速**（解决拉取镜像慢的问题）:

```bash
sudo vi /etc/docker/daemon.json
```

添加以下内容:

```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.1panel.live",
    "https://hub.rat.dev"
  ],
  "dns": ["114.114.114.114", "8.8.8.8"]
}
```

重启 Docker:

```bash
sudo service docker restart
```

**验证安装**:

```bash
docker --version
docker compose version
sudo docker run hello-world
```

如果看到输出内容包含这段信息，就说明测试成功了：

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

#### 方式二：官方安装（国际网络环境）

如果你的服务器可以正常访问 Docker Hub，也可以使用官方安装方法:

- Ubuntu/Debian: https://docs.docker.com/engine/install/ubuntu/
- CentOS/RHEL: https://docs.docker.com/engine/install/centos/

**快速检查**:

```bash
docker --version
docker compose version
```

### 获取项目代码

如果你还没有项目代码,需要先克隆仓库:

**方式一: 使用 Gitee 镜像 (推荐国内用户)**

```bash
git clone --branch master --depth 1 https://gitee.com/honlnk/clash-for-linux-install-docker.git
cd clash-for-linux-install-docker/docker
```

**方式二: 使用 GitHub**

```bash
git clone --branch master --depth 1 https://github.com/nelvko/clash-for-linux-install.git
cd clash-for-linux-install/docker
```

## 快速开始

### 方式一: 使用快速启动脚本 (⭐ 推荐)

```bash
cd docker
./docker-start.sh
```

脚本会自动处理:

1. 检查 Docker 和 Docker Compose
2. 自动使用 sudo (如果需要)
3. 构建镜像
4. 启动容器
5. 显示访问信息和管理命令

### 方式二: 手动使用 docker compose

**执行目录**: `docker/`

1. **配置环境变量** (可选)

```bash
cp .docker.env.example .env
# 编辑 .env 文件,设置订阅链接
```

2. **构建并启动**

```bash
docker compose up -d
```

3. **查看日志**

```bash
docker compose logs -f clash
```

4. **访问 Web 控制台**

```
http://localhost:9091/ui
```

### 方式三: 使用 Docker 命令

**执行目录**: `项目根目录`

1. **构建镜像**

```bash
docker build -f docker/Dockerfile -t clash-for-linux:latest .
```

2. **运行容器**

```bash
docker run -d \
  --name clash \
  --restart unless-stopped \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -p 7891:7890 \
  -p 9091:9090 \
  -p 1054:1053/udp \
  -v clash-data:/root/clashctl/resources \
  clash-for-linux:latest
```

## 配置说明

### 环境变量

| 变量名             | 说明     | 默认值         |
| ------------------ | -------- | -------------- |
| `CLASH_CONFIG_URL` | 订阅链接 | 空(需手动添加) |
| `KERNEL_NAME`      | 内核选择 | mihomo         |

### 端口映射

| 宿主机端口 | 容器端口 | 说明                     |
| --------- | -------- | ------------------------ |
| 7891 | 7890 | HTTP/SOCKS5 混合代理端口 |
| 9091 | 9090 | Web 控制台端口           |
| 1054 | 1053 | DNS 端口                 |

> **注意**: 宿主机端口已调整为 7891/9091/1054，避免与其他服务冲突。

### 数据卷

- `/root/clashctl/resources` - 配置文件持久化目录

> **说明**: 安装路径从 `/opt/clashctl` 更改为 `/root/clashctl`，确保环境一致性。

### 权限要求

- `NET_ADMIN` - TUN 模式需要
- `NET_RAW` - 网络原始套接字权限

## 常用操作

### 添加订阅

```bash
# 进入容器
docker exec -it clash bash

# 添加订阅
clashsub add http://your-subscription-url

# 使用订阅
clashsub use 1

# 查看订阅列表
clashsub ls
```

### 管理代理

```bash
# 开启代理
docker exec clash clashon

# 关闭代理
docker exec clash clashoff

# 查看状态
docker exec clash clashstatus
```

### 更新订阅

```bash
# 更新所有订阅
docker exec clash clashsub update

# 更新指定订阅
docker exec clash clashsub update 1
```

### Web 控制台

```bash
# 查看访问信息
docker exec clash clashui

# 修改密钥
docker exec clash clashsecret mysecret
```

### 查看日志

```bash
# 容器日志
docker compose logs -f clash

# 内核日志
docker exec clash clashlog

# 订阅日志
docker exec clash clashsub log
```

## 容器管理

### 启动/停止/重启

```bash
docker compose start clash
docker compose stop clash
docker compose restart clash
```

### 进入容器

```bash
docker exec -it clash bash
```

### 查看容器状态

```bash
docker ps
docker inspect clash
```

### 删除容器

```bash
docker compose down
# 或
docker stop clash && docker rm clash
```

### 清理数据

```bash
# 删除容器和数据卷
docker compose down -v

# 删除镜像
docker rmi clash-for-linux:latest
```

## TUN 模式

TUN 模式可以实现透明代理,需要额外的权限和网络配置。

### 启用 TUN 模式

```bash
# 编辑 Mixin 配置
docker exec -it clash clashmixin -e

# 修改 tun.enable 为 true
tun:
  enable: true

# 重启容器
docker restart clash
```

### 网络模式

对于 TUN 模式,建议使用 host 网络模式:

```bash
docker run -d \
  --name clash \
  --restart unless-stopped \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  --network host \
  -v clash-data:/root/clashctl/resources \
  clash-for-linux:latest
```

## 安全建议

1. **设置 Web 访问密钥**

```bash
docker exec clash clashsecret your-strong-password
```

2. **开启 allow-lan 时设置认证**

```bash
docker exec clash clashmixin -e
# 修改配置:
# allow-lan: true
# authentication:
#   - "username:password"
```

3. **限制端口暴露**

- 如果只在本地使用,不要暴露 9091 端口到公网
- 使用反向代理(如 Nginx)提供访问控制

## 故障排查

### 容器无法启动

```bash
# 查看日志
docker compose logs clash

# 检查镜像构建
docker images | grep clash
```

### 代理无法连接

```bash
# 检查内核状态
docker exec clash clashstatus

# 检查订阅
docker exec clash clashsub ls

# 查看内核日志
docker exec clash clashlog
```

### Web 控制台无法访问

```bash
# 检查端口是否映射
docker ps | grep clash

# 检查密钥
docker exec clash clashsecret

# 测试连接
curl http://localhost:9091/ui
```

## 参考链接

- [项目主文档](../README.md)
- [Docker 官方文档](https://docs.docker.com/)
- [FAQ](https://github.com/nelvko/clash-for-linux-install/wiki/FAQ)
