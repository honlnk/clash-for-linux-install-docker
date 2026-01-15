#!/usr/bin/env bash

# Clash Docker 快速启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 全局变量
SUDO=""

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

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装,请先安装 Docker"
        exit 1
    fi
    print_info "Docker 已安装: $(docker --version)"
}

# 检查 docker-compose 是否安装
check_docker_compose() {
    if $SUDO docker compose version &> /dev/null 2>&1; then
        print_info "Docker Compose V2 已就绪: $($SUDO docker compose version --short 2>/dev/null)"
        return 0
    fi

    if command -v docker-compose &> /dev/null; then
        print_warn "检测到 Docker Compose V1 (已弃用)"
        return 0
    fi

    print_error "未找到 Docker Compose"
    exit 1
}

# 构建镜像
build_image() {
    print_info "开始构建 Docker 镜像..."

    if $SUDO docker compose version &> /dev/null 2>&1; then
        $SUDO docker compose build
    else
        docker-compose build
    fi

    print_info "镜像构建完成"
}

# 启动容器
start_container() {
    print_info "启动 Clash 容器..."

    if [ -n "$CLASH_CONFIG_URL" ]; then
        print_info "使用订阅链接: $CLASH_CONFIG_URL"
    else
        print_warn "未设置订阅链接,容器启动后需要手动添加订阅"
    fi

    if $SUDO docker compose version &> /dev/null 2>&1; then
        $SUDO docker compose up -d
    else
        docker-compose up -d
    fi

    print_info "容器启动成功"
}

# 显示访问信息
show_access_info() {
    echo ""
    echo "=========================================="
    echo "           😼 Clash 已启动"
    echo "=========================================="
    echo ""
    echo "Web 控制台: http://localhost:9091/ui"
    echo "代理端口: 7891 (HTTP/SOCKS5)"
    echo ""
    echo "常用命令:"
    echo "  查看日志: $SUDO docker compose logs -f clash"
    echo "  停止容器: $SUDO docker compose down"
    echo "  查看状态: $SUDO docker exec clash clashstatus"
    echo "  添加订阅: $SUDO docker exec clash clashsub add <url>"
    echo ""
    echo "⚠️  重要: 容器启动后需要先添加订阅！"
    echo "  $SUDO docker exec clash clashsub add <订阅链接>"
    echo "  $SUDO docker exec clash clashon"
    echo ""
    echo "=========================================="
}

# 主流程
main() {
    echo "😼 Clash Docker 快速启动脚本"
    echo ""

    # 检测是否需要 sudo
    if ! docker info &> /dev/null 2>&1; then
        if sudo -n docker info &> /dev/null 2>&1; then
            print_warn "当前用户没有 docker 权限,将自动使用 sudo"
            SUDO="sudo"
        else
            print_error "当前用户没有 docker 权限,请使用 sudo 运行此脚本"
            exit 1
        fi
    fi

    check_docker
    check_docker_compose
    build_image
    start_container
    show_access_info

    print_info "完成! 使用 '$SUDO docker compose logs -f clash' 查看日志"
}

main "$@"
