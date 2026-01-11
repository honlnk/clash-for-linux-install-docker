#!/usr/bin/env bash

# Clash Docker 快速启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装,请先安装 Docker"
        echo "访问 https://docs.docker.com/get-docker/ 获取安装指南"
        exit 1
    fi
    print_info "Docker 已安装: $(docker --version)"
}

# 检查 docker-compose 是否安装
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "docker-compose 未安装"
        echo "请安装 docker-compose 或使用 Docker Compose V2"
        exit 1
    fi
    print_info "Docker Compose 已就绪"
}

# 构建镜像
build_image() {
    print_info "开始构建 Docker 镜像..."
    if docker compose version &> /dev/null; then
        docker compose build
    else
        docker-compose build
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

    if docker compose version &> /dev/null; then
        docker compose up -d
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
    echo "Web 控制台: http://localhost:9090/ui"
    echo "代理端口: 7890 (HTTP/SOCKS5)"
    echo "DNS 端口: 1053"
    echo ""
    echo "常用命令:"
    echo "  查看日志: docker compose logs -f clash"
    echo "  查看状态: docker exec clash clashstatus"
    echo "  添加订阅: docker exec clash clashsub add <url>"
    echo "  进入容器: docker exec -it clash bash"
    echo ""
    echo "=========================================="
}

# 主流程
main() {
    echo "😼 Clash Docker 快速启动脚本"
    echo ""

    check_docker
    check_docker_compose
    build_image
    start_container
    show_access_info

    print_info "完成! 使用 'docker compose logs -f clash' 查看日志"
}

# 执行主流程
main "$@"
