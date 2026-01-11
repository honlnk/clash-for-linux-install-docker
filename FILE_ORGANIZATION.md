# 文件整理说明

## .env 文件说明

项目中有两个不同的 `.env` 配置文件,用途不同:

### 1. 根目录的 `.env`
- **用途**: 直接安装时的配置文件
- **使用方式**: `bash install.sh` 时自动读取
- **配置项**: 安装路径、内核选择、订阅链接、版本号等
- **重要性**: 必须保留在根目录

### 2. docker 目录的 `.docker.env.example`
- **用途**: Docker 部署时的环境变量模板
- **使用方式**: Docker Compose 或 docker run 的环境变量
- **配置项**: 订阅链接、内核选择等容器相关配置
- **位置**: `docker/.docker.env.example`

## 示例

### 直接安装使用根目录 .env
```bash
# 编辑配置
vim .env

# 安装(会自动读取 .env)
bash install.sh
```

### Docker 部署使用 docker/.docker.env.example
```bash
cd docker

# 配置环境变量
cp .docker.env.example .env
vim .env

# 启动容器
docker-compose up -d
```

## 为什么分开?

1. **避免混淆**: 直接安装和 Docker 部署的配置需求不同
2. **安全性**: Docker 不需要知道安装路径、版本号等信息
3. **清晰**: 各自关注自己的配置范围

## 注意事项

- ❌ 不要将根目录的 `.env` 用于 Docker
- ❌ 不要将 docker 目录的 `.docker.env.example` 用于直接安装
- ✅ 使用对应的配置文件进行配置
