#!/usr/bin/env bash

# Clash Docker 快速启动脚本

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

# 检测网络环境,选择合适的构建方式
detect_network_env() {
    print_step "检测网络环境..."

    # 尝试连接 Docker Hub
    if timeout 5 curl -s --head https://registry-1.docker.io/v2/ > /dev/null 2>&1; then
        print_info "✅ 国际网络畅通,使用官方 Docker 镜像"
        COMPOSE_FILE="docker-compose.yml"
        return 0
    else
        print_warn "⚠️  国际网络受限,将使用国内镜像优化版本"
        COMPOSE_FILE="docker-compose.china.yml"
        return 1
    fi
}

# 检测是否需要 sudo
SUDO=""
if ! docker info &> /dev/null; then
    if sudo -n docker info &> /dev/null 2>&1; then
        print_warn "当前用户没有 docker 权限,将自动使用 sudo"
        SUDO="sudo"
    else
        print_error "当前用户没有 docker 权限,且无法自动使用 sudo"
        echo ""
        echo "请选择以下方式之一:"
        echo "  1. 使用 sudo 运行此脚本: sudo $0"
        echo "  2. 将当前用户添加到 docker 组:"
        echo "     sudo usermod -aG docker \$USER"
        echo "     newgrp docker  # 或重新登录"
        echo ""
        exit 1
    fi
fi

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装,请先安装 Docker"
        echo "访问 docker/DOCKER_INSTALL.md 查看安装指南"
        exit 1
    fi
    print_info "Docker 已安装: $(docker --version)"
}

# 检查 docker-compose 是否安装
check_docker_compose() {
    # 优先检查 Docker Compose V2 (内置插件)
    if $SUDO docker compose version &> /dev/null 2>&1; then
        print_info "Docker Compose V2 已就绪: $($SUDO docker compose version --short 2>/dev/null)"
        return 0
    fi

    # 回退到 Docker Compose V1
    if command -v docker-compose &> /dev/null; then
        print_warn "检测到 Docker Compose V1 (已弃用)"
        print_info "建议升级到 Docker Compose V2"
        return 0
    fi

    # 都没有安装
    print_error "未找到 Docker Compose"
    echo ""
    echo "请选择以下方式之一安装:"
    echo "  1. 推荐方式: 安装 Docker Compose V2 (已包含在 Docker 中)"
    echo "     检查 Docker 版本: $SUDO docker --version"
    echo "     使用 Compose V2: $SUDO docker compose version"
    echo ""
    echo "  2. 或者安装 V1 (不推荐):"
    echo "     sudo apt install docker-compose"
    echo ""
    exit 1
}

# 构建镜像
build_image() {
    print_info "开始构建 Docker 镜像..."
    print_info "使用配置文件: $COMPOSE_FILE"

    # 优先使用 Docker Compose V2
    if $SUDO docker compose version &> /dev/null 2>&1; then
        $SUDO docker compose -f $COMPOSE_FILE build
    else
        # 回退到 V1
        docker-compose -f $COMPOSE_FILE build
    fi

    print_info "镜像构建完成"
}

# 启动容器
start_container() {
    print_info "启动 Clash 容器..."

    # 检查是否提供了订阅链接
    if [ -n "$CLASH_CONFIG_URL" ]; then
        print_info "使用订阅链接: $CLASH_CONFIG_URL"
    else
        print_warn "未设置订阅链接,容器启动后需要手动添加订阅"
        print_info "提示: export CLASH_CONFIG_URL=http://your-url && ./docker-start.sh"
    fi

    # 优先使用 Docker Compose V2
    if $SUDO docker compose version &> /dev/null 2>&1; then
        $SUDO docker compose -f $COMPOSE_FILE up -d
    else
        # 回退到 V1
        docker-compose -f $COMPOSE_FILE up -d
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
    echo "Web 控制台: http://localhost:9090/ui"
    echo "代理端口: 7890 (HTTP/SOCKS5)"
    echo "DNS 端口: 1053"
    echo ""
    echo "常用命令:"

    # 根据可用的 Compose 版本显示不同的命令
    if $SUDO docker compose version &> /dev/null 2>&1; then
        echo "  查看日志: $SUDO docker compose -f $COMPOSE_FILE logs -f clash"
        echo "  停止容器: $SUDO docker compose -f $COMPOSE_FILE down"
        echo "  重启容器: $SUDO docker compose -f $COMPOSE_FILE restart"
    else
        echo "  查看日志: docker-compose -f $COMPOSE_FILE logs -f clash"
        echo "  停止容器: docker-compose -f $COMPOSE_FILE down"
        echo "  重启容器: docker-compose -f $COMPOSE_FILE restart"
    fi

    echo "  查看状态: $SUDO docker exec clash clashstatus"
    echo "  添加订阅: $SUDO docker exec clash clashsub add <url>"
    echo "  进入容器: $SUDO docker exec -it clash bash"
    echo ""
    echo "=========================================="
}

# 主流程
main() {
    echo "😼 Clash Docker 快速启动脚本"
    echo ""

    detect_network_env
    check_docker
    check_docker_compose
    build_image
    start_container
    show_access_info

    print_info "完成! 使用 '$SUDO docker compose -f $COMPOSE_FILE logs -f clash' 查看日志"
}

# 执行主流程
main "$@"
