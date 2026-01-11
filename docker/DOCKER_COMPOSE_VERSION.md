# Docker Compose 版本说明

本文档说明 Docker Compose V1 和 V2 的区别及使用方法。

## 版本对比

| 特性 | Docker Compose V1 | Docker Compose V2 |
|------|-------------------|-------------------|
| **命令格式** | `docker-compose` | `docker compose` |
| **安装方式** | 单独安装 | 内置在 Docker 中 |
| **状态** | 已弃用 (2023年7月) | ✅ 推荐 |
| **发布时间** | 2014年 | 2021年 |
| **集成方式** | 独立二进制文件 | Docker 插件 |

## 检查你的版本

```bash
# 检查 V2 (推荐)
docker compose version
# 输出示例: Docker Compose version v2.24.5

# 检查 V1 (已弃用)
docker-compose --version
# 输出示例: docker-compose version 1.29.2
```

## 命令对照表

| 操作 | V1 命令 | V2 命令 (推荐) |
|------|---------|----------------|
| **启动** | `docker-compose up -d` | `docker compose up -d` |
| **停止** | `docker-compose down` | `docker compose down` |
| **重启** | `docker-compose restart` | `docker compose restart` |
| **查看日志** | `docker-compose logs -f` | `docker compose logs -f` |
| **查看状态** | `docker-compose ps` | `docker compose ps` |
| **构建镜像** | `docker-compose build` | `docker compose build` |
| **拉取镜像** | `docker-compose pull` | `docker compose pull` |

## 本项目中的使用

### 文档中的命令

本项目文档统一使用 **V2 语法** (`docker compose`):

```bash
# 启动容器
docker compose up -d

# 查看日志
docker compose logs -f clash

# 停止容器
docker compose down
```

### 如果你使用的是 V1

**选项 1: 升级到 V2 (推荐)**

V2 通常已经包含在你的 Docker 安装中,无需额外安装:

```bash
# 检查是否已有 V2
docker compose version

# 如果显示版本号,说明已安装,可以直接使用
# 如果显示 "command not found",请更新 Docker
```

更新 Docker 到最新版本:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**选项 2: 继续使用 V1**

如果必须使用 V1,请将文档中的命令进行替换:

- `docker compose` → `docker-compose`
- `docker compose up -d` → `docker-compose up -d`
- `docker compose logs -f` → `docker-compose logs -f`
- `docker compose down` → `docker-compose down`

### 脚本兼容性

本项目的 `docker-start.sh` 脚本**自动兼容两个版本**:

```bash
./docker-start.sh  # 自动检测并使用可用的版本
```

脚本会:
1. 优先使用 V2 (`docker compose`)
2. 如果 V2 不可用,回退到 V1 (`docker-compose`)
3. 自动处理权限问题 (sudo)

## 为什么推荐 V2?

### 优势

1. **无需单独安装** - 内置在 Docker 中
2. **性能更好** - 直接与 Docker daemon 通信
3. **功能更强大** - 支持更多新特性
4. **官方推荐** - V1 已于 2023年7月停止更新
5. **更好的集成** - 与 Docker CLI 无缝集成

### 迁移建议

如果你目前使用 V1:

```bash
# 1. 检查 V2 是否可用
docker compose version

# 2. 如果可用,测试一下
docker compose up -d

# 3. 如果一切正常,卸载 V1
sudo apt remove docker-compose

# 4. 更新你的脚本和文档
# 将 docker-compose 替换为 docker compose
```

## 常见问题

### Q: 我应该使用哪个版本?

**A**: 使用 V2 (`docker compose`)
- V1 已停止更新
- V2 是未来的标准
- 两者语法基本兼容

### Q: 为什么我的系统只有 V1?

**A**: 可能是旧版本的 Docker
```bash
# 更新 Docker
sudo apt update
sudo apt upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Q: V2 会影响我的 docker-compose.yml 文件吗?

**A**: 不会!
- `docker-compose.yml` 文件格式完全兼容
- 两个版本使用相同的配置文件
- 只需要改命令,不需要改配置

### Q: 如何在脚本中兼容两个版本?

**A**: 参考本项目的 `docker-start.sh` 脚本

```bash
if docker compose version &> /dev/null 2>&1; then
    # 使用 V2
    docker compose up -d
else
    # 回退到 V1
    docker-compose up -d
fi
```

## 参考链接

- [Docker 官方博客: Compose V2 发布](https://www.docker.com/blog/docker-compose-v2/)
- [Docker Compose V2 迁移指南](https://docs.docker.com/compose/migrate/)
- [Docker Compose 官方文档](https://docs.docker.com/compose/)

---

**总结**: 新项目统一使用 V2,老项目建议尽快迁移。本项目已完全兼容 V2 并优先使用 V2 语法。
