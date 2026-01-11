# Clash Docker 部署指南

本文档介绍如何使用 Docker 部署 clash-for-linux-install 项目。

## 快速开始

### 方式一: 使用 docker-compose (推荐)

1. **配置环境变量** (可选)
```bash
# 方式1: 直接在 docker-compose.yml 中修改
# 方式2: 使用环境变量文件
cp .docker.env.example .env
# 编辑 .env 文件,设置订阅链接
# export CLASH_CONFIG_URL=http://your-subscription-url
```

2. **构建并启动**
```bash
docker-compose up -d
```

3. **查看日志**
```bash
docker-compose logs -f clash
```

4. **访问 Web 控制台**
```
http://localhost:9090/ui
```

### 方式二: 使用 Docker 命令

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
  -p 7890:7890 \
  -p 9090:9090 \
  -p 1053:1053/udp \
  -v clash-data:/opt/clashctl/resources \
  -e CLASH_CONFIG_URL=http://your-subscription-url \
  clash-for-linux:latest
```

3. **查看状态**
```bash
docker ps
docker logs clash
```

## 配置说明

### 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `CLASH_CONFIG_URL` | 订阅链接 | 空(需手动添加) |
| `KERNEL_NAME` | 内核选择 | mihomo |

### 端口映射

| 端口 | 说明 |
|------|------|
| 7890 | HTTP/SOCKS5 混合代理端口 |
| 9090 | Web 控制台端口 |
| 1053 | DNS 端口 |

### 数据卷

- `/opt/clashctl/resources` - 配置文件持久化目录

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
docker logs -f clash

# 内核日志
docker exec clash clashlog

# 订阅日志
docker exec clash clashsub log
```

### Mixin 配置

```bash
# 编辑 Mixin 配置
docker exec clash clashmixin -e

# 查看运行时配置
docker exec clash clashmixin -r

# 重启应用配置
docker exec clash clashoff && docker exec clash clashon
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
  -v clash-data:/opt/clashctl/resources \
  clash-for-linux:latest
```

或者在 docker-compose.yml 中修改:
```yaml
network_mode: host
```

## 容器管理命令

### 启动/停止/重启

```bash
docker-compose start clash
docker-compose stop clash
docker-compose restart clash
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
docker-compose down
# 或
docker stop clash && docker rm clash
```

### 清理数据

```bash
# 删除容器和数据卷
docker-compose down -v

# 删除镜像
docker rmi clash-for-linux:latest
```

## 故障排查

### 容器无法启动

```bash
# 查看日志
docker logs clash

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
curl http://localhost:9090/ui
```

### 订阅更新失败

```bash
# 查看订阅日志
docker exec clash clashsub log

# 手动更新
docker exec clash clashsub update

# 检查网络连接
docker exec clash curl -I http://www.google.com
```

## 高级配置

### 使用本地配置文件

```bash
# 挂载本地配置
docker run -d \
  --name clash \
  -p 7890:7890 \
  -p 9090:9090 \
  -v $(pwd)/config.yaml:/opt/clashctl/resources/config.yaml:ro \
  -v clash-data:/opt/clashctl/resources \
  clash-for-linux:latest
```

### 自定义 Mixin 配置

```bash
# 挂载自定义 mixin
docker run -d \
  --name clash \
  -p 7890:7890 \
  -p 9090:9090 \
  -v $(pwd)/mixin.yaml:/opt/clashctl/resources/mixin.yaml:ro \
  -v clash-data:/opt/clashctl/resources \
  clash-for-linux:latest
```

### 多实例部署

```bash
# 实例 1
docker run -d \
  --name clash1 \
  -p 7890:7890 -p 9090:9090 \
  -v clash1-data:/opt/clashctl/resources \
  clash-for-linux:latest

# 实例 2 (使用不同端口)
docker run -d \
  --name clash2 \
  -p 7891:7890 -p 9091:9090 \
  -v clash2-data:/opt/clashctl/resources \
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
- 如果只在本地使用,不要暴露 9090 端口到公网
- 使用反向代理(如 Nginx)提供访问控制

4. **定期更新内核**
```bash
docker exec clash clashupgrade
```

## 性能优化

1. **调整资源限制**
```yaml
# docker-compose.yml
services:
  clash:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 512M
```

2. **使用 host 网络模式** (避免 NAT 性能损耗)
```bash
--network host
```

3. **调整 DNS 缓存**
```yaml
# 在 mixin.yaml 中
dns:
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
```

## 参考链接

- [项目主文档](README.md)
- [FAQ](https://github.com/nelvko/clash-for-linux-install/wiki/FAQ)
- [Docker 官方文档](https://docs.docker.com/)
