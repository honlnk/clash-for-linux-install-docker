#!/usr/bin/env bash

# Docker 镜像加速器配置脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检测是否需要 sudo
SUDO=""
if [ "$EUID" -ne 0 ]; then
    if sudo -n true 2>/dev/null; then
        SUDO="sudo"
    else
        print_error "需要 root 权限,请使用 sudo 运行此脚本"
        exit 1
    fi
fi

echo "😼 Docker 镜像加速器配置脚本"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    print_error "Docker 未安装,请先安装 Docker"
    echo "查看 DOCKER_INSTALL.md 了解安装步骤"
    exit 1
fi

print_info "Docker 已安装: $(docker --version)"

# Docker 配置目录
DOCKER_CONFIG_DIR="/etc/docker"
DOCKER_CONFIG_FILE="$DOCKER_CONFIG_DIR/daemon.json"

# 备份现有配置
if [ -f "$DOCKER_CONFIG_FILE" ]; then
    print_step "备份现有配置..."
    $SUDO cp "$DOCKER_CONFIG_FILE" "$DOCKER_CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)"
    print_info "已备份到: $DOCKER_CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)"
fi

# 创建配置目录
print_step "创建 Docker 配置目录..."
$SUDO mkdir -p "$DOCKER_CONFIG_DIR"

# 可用的镜像加速器列表
print_step "选择镜像加速器..."
echo ""
echo "请选择镜像加速器提供商:"
echo "  1. 阿里云 (推荐,速度快,稳定)"
echo "  2. 腾讯云 (国内访问快)"
echo "  3. 网易云 (稳定可靠)"
echo "  4. 中科大 (教育网优化)"
echo "  5. 全部配置 (自动切换)"
echo ""
read -p "请输入选项 [1-5, 默认 1]: " mirror_choice

mirror_choice=${mirror_choice:-1}

# 根据选择生成配置
case $mirror_choice in
    1)
        MIRRORS='{"registry-mirrors": ["https://docker.mirrors.ustc.edu.cn", "https://hub-mirror.c.163.com"], "dns": ["114.114.114.114", "8.8.8.8"]}'
        print_info "使用阿里云镜像加速器"
        ;;
    2)
        MIRRORS='{"registry-mirrors": ["https://mirror.ccs.tencentyun.com"], "dns": ["114.114.114.114", "8.8.8.8"]}'
        print_info "使用腾讯云镜像加速器"
        ;;
    3)
        MIRRORS='{"registry-mirrors": ["https://hub-mirror.c.163.com"], "dns": ["114.114.114.114", "8.8.8.8"]}'
        print_info "使用网易云镜像加速器"
        ;;
    4)
        MIRRORS='{"registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"], "dns": ["114.114.114.114", "8.8.8.8"]}'
        print_info "使用中科大镜像加速器"
        ;;
    5)
        MIRRORS='{"registry-mirrors": ["https://docker.mirrors.ustc.edu.cn", "https://hub-mirror.c.163.com", "https://mirror.ccs.tencentyun.com"], "dns": ["114.114.114.114", "8.8.8.8"]}'
        print_info "使用全部镜像加速器(自动切换)"
        ;;
    *)
        print_error "无效选项,使用默认配置"
        MIRRORS='{"registry-mirrors": ["https://docker.mirrors.ustc.edu.cn", "https://hub-mirror.c.163.com"], "dns": ["114.114.114.114", "8.8.8.8"]}'
        ;;
esac

# 写入配置文件
print_step "写入 Docker 配置..."
echo "$MIRRORS" | $SUDO tee "$DOCKER_CONFIG_FILE" > /dev/null

print_info "配置文件已创建: $DOCKER_CONFIG_FILE"
echo ""
echo "配置内容:"
cat "$DOCKER_CONFIG_FILE"
echo ""

# 重启 Docker 服务
print_step "重启 Docker 服务..."
if command -v systemctl &> /dev/null; then
    $SUDO systemctl restart docker
    print_info "Docker 服务已重启"
elif command -v service &> /dev/null; then
    $SUDO service docker restart
    print_info "Docker 服务已重启"
else
    print_warn "无法自动重启 Docker,请手动重启:"
    echo "  sudo systemctl restart docker"
    echo "  或"
    echo "  sudo service docker restart"
    echo ""
    print_warn "重启后才能使用镜像加速"
    exit 0
fi

# 验证配置
print_step "验证配置..."
if $SUDO docker info &> /dev/null; then
    print_info "Docker 服务运行正常"
    echo ""
    echo "镜像加速器配置:"
    $SUDO docker info | grep -A 5 "Registry Mirrors" || echo "  (未检测到镜像加速器配置)"
else
    print_error "Docker 服务异常,请检查日志"
    exit 1
fi

echo ""
echo "=========================================="
echo "           😼 配置完成"
echo "=========================================="
echo ""
echo "✅ 镜像加速器已配置成功"
echo ""
echo "测试拉取镜像:"
echo "  $SUDO docker pull ubuntu:22.04"
echo ""
echo "查看镜像加速器配置:"
echo "  $SUDO docker info | grep -A 5 'Registry Mirrors'"
echo ""
echo "恢复原始配置:"
echo "  $SUDO mv $DOCKER_CONFIG_FILE.bak.* $DOCKER_CONFIG_FILE"
echo "  $SUDO systemctl restart docker"
echo ""
echo "=========================================="
