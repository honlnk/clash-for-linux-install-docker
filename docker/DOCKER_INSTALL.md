# Docker 安装指南

在部署 Clash Docker 容器之前,你需要先在服务器上安装 Docker。本文档提供详细的 Docker 安装步骤。

## 🚀 快速开始

### 国内服务器推荐安装方式

如果你的服务器在国内,**强烈建议使用国内镜像源**,避免网络问题:

```bash
# 使用清华大学镜像源安装 Docker (推荐)
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker

# 验证安装
sudo docker run hello-world
```

> ✅ **完成!** 如果看到 "Hello from Docker!" 消息,说明安装成功。
>
> 📖 如需更多安装方式或遇到问题,请查看下方详细章节。

---

## 目录

- [系统要求](#系统要求)
- [Ubuntu/Debian 系统](#ubuntudebian-系统)
- [CentOS/RHEL 系统](#centosrhel-系统)
- [验证安装](#验证安装)
- [卸载 Docker](#卸载-docker)
- [常见问题](#常见问题)
- [国内用户特别提示](#国内用户特别提示)

---

## 系统要求

**支持的操作系统**:
- Ubuntu 22.04/24.04 LTS (Jammy/Noble)
- Debian 11/12 (Bullseye/Bookworm)
- CentOS 7/8/9
- RHEL 8/9

**系统架构**:
- x86_64/amd64
- arm64 (aarch64)
- armhf

**最低配置**:
- 内存: 2GB RAM
- 磁盘: 20GB 可用空间
- CPU: 2 核心处理器

---

## Ubuntu/Debian 系统

### 方式一: 使用 apt 仓库安装 (推荐)

这是官方推荐的安装方式,可以方便地更新和管理 Docker。

#### 步骤 1: 卸载旧版本 (如果存在)

如果你的系统中已经安装了非官方的 Docker 包,需要先卸载:

```bash
sudo apt remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
```

> 💡 **提示**: `apt` 可能会报告没有安装这些包,这是正常的。

#### 步骤 2: 更新包索引并安装依赖

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
```

#### 步骤 3: 添加 Docker 的官方 GPG 密钥

```bash
# 创建 keyrings 目录
sudo install -m 0755 -d /etc/apt/keyrings

# 下载并添加 Docker GPG 密钥
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# 设置密钥文件权限
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

#### 步骤 4: 添加 Docker 仓库到 Apt 源

```bash
# 添加 Docker 仓库
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# 如果是 Debian 系统,将上面的 URL 改为:
# URIs: https://download.docker.com/linux/debian
```

#### 步骤 5: 更新包索引

```bash
sudo apt update
```

#### 步骤 6: 安装 Docker 及相关组件

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**安装的组件说明**:
- `docker-ce`: Docker Engine
- `docker-ce-cli`: Docker 命令行界面
- `containerd.io`: 容器运行时
- `docker-buildx-plugin`: Docker Buildx 构建工具
- `docker-compose-plugin`: Docker Compose V2

#### 步骤 7: 启动 Docker 服务

```bash
# Docker 安装后会自动启动,如果没有自动启动,执行:
sudo systemctl start docker

# 设置开机自启
sudo systemctl enable docker

# 查看 Docker 状态
sudo systemctl status docker
```

---

### 方式二: 使用官方安装脚本 (快速但不推荐生产环境)

> ⚠️ **警告**: 此方式仅推荐用于开发和测试环境,不建议用于生产环境!
>
> 原因:
> - 无法自定义安装参数
> - 可能安装大量不需要的依赖包
> - 可能导致意外的版本升级

```bash
# 下载安装脚本
curl -fsSL https://get.docker.com -o get-docker.sh

# (可选) 预览脚本将执行的操作
sudo sh get-docker.sh --dry-run

# 执行安装
sudo sh get-docker.sh

# 验证安装
sudo docker run hello-world
```

---

## CentOS/RHEL 系统

### 使用 yum 仓库安装

#### 步骤 1: 卸载旧版本

```bash
sudo yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine
```

#### 步骤 2: 安装依赖

```bash
sudo yum install -y yum-utils
```

#### 步骤 3: 添加 Docker 仓库

```bash
# CentOS/RHEL 8/9
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 如果使用 RHEL,使用以下 URL:
# https://download.docker.com/linux/rhel/docker-ce.repo
```

#### 步骤 4: 安装 Docker

```bash
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### 步骤 5: 启动 Docker

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 验证安装

### 基础验证

```bash
# 查看 Docker 版本
docker --version

# 查看 Docker Compose 版本
docker compose version

# 查看详细信息
docker info
```

### 运行测试容器

```bash
# 运行 hello-world 测试镜像
sudo docker run hello-world
```

如果看到以下输出,说明安装成功:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

### 检查 Docker 服务状态

```bash
# 查看 Docker 服务状态
sudo systemctl status docker

# 查看 Docker 服务日志
sudo journalctl -u docker -n 50 --no-pager
```

---

## 配置免 sudo 运行 Docker (可选)

默认情况下,需要使用 `sudo` 来运行 Docker 命令。如果想让当前用户免 sudo 运行 Docker:

```bash
# 1. 创建 docker 组 (如果不存在)
sudo groupadd docker

# 2. 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 3. 重新登录或运行以下命令使更改生效
newgrp docker

# 4. 验证是否可以免 sudo 运行
docker run hello-world
```

> ⚠️ **安全警告**: 将用户添加到 `docker` 组等同于授予其 root 权限,请谨慎操作!

---

## 卸载 Docker

### 卸载 Docker 包

**Ubuntu/Debian**:
```bash
sudo apt purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**CentOS/RHEL**:
```bash
sudo yum remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 删除所有镜像、容器和卷

```bash
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

### 删除配置文件

**Ubuntu/Debian**:
```bash
sudo rm /etc/apt/sources.list.d/docker.sources
sudo rm /etc/apt/keyrings/docker.asc
```

**CentOS/RHEL**:
```bash
sudo rm /etc/yum.repos.d/docker-ce.repo
```

---

## 常见问题

### Q1: 安装后 Docker 服务无法启动

**症状**:
```bash
sudo systemctl start docker
# 报错: Job for docker.service failed
```

**解决方案**:
```bash
# 查看详细错误日志
sudo journalctl -u docker.service -n 50 --no-pager

# 常见原因:
# 1. 端口冲突 - 检查是否有其他服务占用相关端口
# 2. 权限问题 - 确保文件权限正确
# 3. 配置错误 - 检查 /etc/docker/daemon.json 配置
```

### Q2: docker run 命令需要 sudo

**解决方案**: 按照[配置免 sudo 运行 Docker](#配置免-sudo-运行-docker-可选)的步骤操作。

### Q3: 无法连接到 Docker daemon

**症状**:
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**解决方案**:
```bash
# 检查 Docker 服务是否运行
sudo systemctl status docker

# 如果未运行,启动服务
sudo systemctl start docker

# 如果服务运行正常但仍报错,检查 socket 文件
ls -l /var/run/docker.sock
```

### Q4: 国内服务器下载 Docker 镜像慢

**解决方案**: 配置 Docker 镜像加速器

创建或编辑 `/etc/docker/daemon.json`:
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF

# 重启 Docker 服务
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### Q5: Firewall 与 Docker 冲突

**问题**: Docker 会修改 iptables 规则,可能与 UFW 或 firewalld 冲突。

**解决方案**: 参考 [Docker 官方防火墙文档](https://docs.docker.com/engine/iptables/)

### Q6: CentOS/RHEL 安装失败

**问题**: 出现 package dependency 错误

**解决方案**:
```bash
# 检查系统版本
cat /etc/os-release

# 确保使用正确的仓库
# CentOS 7: 使用 centos 仓库
# CentOS 8/9: 使用 centos 仓库
# RHEL: 使用 rhel 仓库
```

---

## 国内用户特别提示

> ⚠️ **重要提示**: 如果你的服务器在国内且**还没有安装代理工具**,直接访问 `download.docker.com` 可能会失败或速度很慢。
>
> **推荐解决方案**:
> 1. **使用系统级代理** (如果服务器上有其他代理工具)
> 2. **使用国内镜像源** (见下文)
> 3. **使用 VPS 中转** (如果有境外 VPS)

### 方案一: 使用国内镜像源安装 Docker

Ubuntu/Debian 系统可以使用清华大学或阿里云的镜像源:

#### 使用清华大学镜像源 (推荐)

```bash
# 1. 卸载旧版本 (如果存在)
sudo apt remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc

# 2. 更新包索引并安装依赖
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# 3. 添加 Docker GPG 密钥 (使用清华大学镜像)
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 4. 添加 Docker 仓库 (使用清华大学镜像)
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# 5. 更新包索引
sudo apt update

# 6. 安装 Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 7. 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker

# 8. 验证安装
sudo docker run hello-world
```

#### 使用阿里云镜像源

```bash
# 步骤 1-2 同上

# 3. 添加 Docker GPG 密钥 (使用阿里云镜像)
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 4. 添加 Docker 仓库 (使用阿里云镜像)
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://mirrors.aliyun.com/docker-ce/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# 步骤 5-8 同上
```

#### 中科大镜像源

```bash
# 使用中科大镜像源
sudo curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

> 💡 **提示**: 这些镜像源会定期同步 Docker 官方仓库,版本可能略有延迟,但通常在 24 小时内同步。

### 方案二: 使用系统代理 (如果有其他代理工具)

如果你的服务器上有其他代理工具 (如 shadowsocks、v2ray 等),可以配置系统代理:

```bash
# 设置代理环境变量
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"

# 然后执行安装命令
sudo -E apt update
sudo -E apt install -y ca-certificates curl

# curl 命令会自动使用代理
sudo -E curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
```

> 💡 **说明**: `sudo -E` 会保留当前的环境变量 (包括代理设置)

### 方案三: 手动下载 deb 包安装

如果镜像源也无法访问,可以手动下载 deb 包:

```bash
# 1. 在本地电脑 (有代理的电脑) 下载 deb 包
# 访问: https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/
# 选择你的 Ubuntu 版本和架构 (amd64/arm64)

# 需要下载的包:
# - containerd.io_<version>_<arch>.deb
# - docker-ce_<version>_<arch>.deb
# - docker-ce-cli_<version>_<arch>.deb
# - docker-buildx-plugin_<version>_<arch>.deb
# - docker-compose-plugin_<version>_<arch>.deb

# 2. 上传到服务器 (使用 scp 或 sftp)
scp *.deb user@server:/tmp/

# 3. 在服务器上安装
sudo dpkg -i /tmp/*.deb

# 4. 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 方案四: 使用离线安装包

Docker 官方提供了一些离线安装包,可以下载后在服务器上安装:

```bash
# 1. 下载离线安装包 (在本地电脑)
# 访问: https://download.docker.com/linux/ubuntu/dists/
# 或使用镜像站

# 2. 上传并安装 (同方案三)
```

---

### 使用国内镜像加速

**阿里云镜像加速器**:
```bash
sudo tee /etc/docker/daemon.json > /dev/null <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 网络问题

如果在安装过程中无法访问 `download.docker.com`,可以:

1. **使用代理**:
   ```bash
   export http_proxy=http://your-proxy:port
   export https_proxy=http://your-proxy:port
   ```

2. **使用国内镜像源** (不推荐,可能不是最新版本):
   - 使用云服务商提供的 Docker 源
   - 使用第三方镜像站

---

## 下一步

Docker 安装完成后,你可以:

1. 📖 阅读 [Docker 部署指南](DOCKER.md)
2. 🚀 开始部署 Clash 容器
3. 📚 学习更多 Docker 命令:
   - [Docker 官方文档](https://docs.docker.com/)
   - [Docker Compose 文档](https://docs.docker.com/compose/)

---

## 参考链接

- [Docker 官方 Ubuntu 安装指南](https://docs.docker.com/engine/install/ubuntu/)
- [Docker 官方 Debian 安装指南](https://docs.docker.com/engine/install/debian/)
- [Docker 官方 CentOS 安装指南](https://docs.docker.com/engine/install/centos/)
- [Docker 官方 RHEL 安装指南](https://docs.docker.com/engine/install/rhel/)
- [Docker Linux 后安装步骤](https://docs.docker.com/engine/install/linux-postinstall/)
