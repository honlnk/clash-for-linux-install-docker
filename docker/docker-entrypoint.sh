#!/usr/bin/env bash

set -e

# 加载 clashctl 命令
# 注意：路径必须与Dockerfile中的CLASH_BASE_DIR保持一致
. /root/clashctl/scripts/cmd/clashctl.sh

# 显示欢迎信息
show_welcome() {
    cat <<'EOF'
╔═══════════════════════════════════════════════╗
║           😼 Clash Docker 容器               ║
║═══════════════════════════════════════════════║
║                                               ║
║  Web 控制台: http://localhost:9090/ui         ║
║  (宿主机访问: http://localhost:9091/ui)       ║
║                                               ║
║  代理端口: 7890 (HTTP/SOCKS5)                 ║
║  (宿主机访问: localhost:7891)                 ║
║                                               ║
║  DNS 端口: 1053                               ║
║  (宿主机访问: localhost:1054)                 ║
║                                               ║
╚═══════════════════════════════════════════════╝
EOF
}

# 确保 Docker 配置正确
ensure_docker_config() {
    echo "🔧 检查 Docker 配置..."

    local mixin_file="/root/clashctl/resources/mixin.yaml"

    # 使用 yq 确保 allow-lan 和 bind-address 配置正确
    /root/clashctl/bin/yq eval '.allow-lan = true' -i "$mixin_file" 2>/dev/null
    /root/clashctl/bin/yq eval '.bind-address = "*"' -i "$mixin_file" 2>/dev/null
    /root/clashctl/bin/yq eval '.external-controller = "0.0.0.0:9090"' -i "$mixin_file" 2>/dev/null

    echo "✅ Docker 配置已更新 (allow-lan: true, bind-address: *)"
}

# 初始化配置
init_config() {
    # 如果提供了订阅链接,自动添加
    if [ -n "$CLASH_CONFIG_URL" ]; then
        echo "😼 检测到订阅链接,正在添加..."
        clashsub add "$CLASH_CONFIG_URL" 2>/dev/null || true

        # 获取第一个订阅的ID
        local first_id=$(/root/clashctl/bin/yq '.profiles[0].id // 0' /root/clashctl/resources/profiles.yaml 2>/dev/null)

        if [ "$first_id" != "0" ] && [ "$first_id" != "null" ]; then
            echo "😼 使用订阅 [$first_id]"
            clashsub use "$first_id" 2>/dev/null || true
        fi
    fi
}

# 启动 clash
start_clash() {
    echo "😼 启动 Clash 内核..."

    # 尝试启动内核，即使失败也不退出容器
    if clashon 2>/dev/null; then
        # 等待内核启动
        sleep 2

        if clashstatus >/dev/null 2>&1; then
            echo "✅ Clash 内核启动成功!"

            # 显示当前密钥
            local secret=$(/root/clashctl/bin/yq '.secret // ""' /root/clashctl/resources/runtime.yaml 2>/dev/null)
            if [ -n "$secret" ]; then
                echo "🔑 Web 访问密钥: $secret"
            fi

            # 显示订阅信息
            echo ""
            clashsub ls 2>/dev/null || echo "⚠️  尚未添加订阅,请使用 docker exec 添加:"
            echo "   docker exec -it clash clashsub add <订阅链接>"
        else
            echo "⚠️  Clash 内核启动失败(可能没有订阅)"
            echo "💡 容器将继续运行，请添加订阅后手动启动："
            echo "   docker exec -it clash clashsub add <订阅链接>"
            echo "   docker exec -it clash clashon"
        fi
    else
        echo "⚠️  Clash 内核启动失败(可能没有订阅)"
        echo "💡 容器将继续运行，请添加订阅后手动启动："
        echo "   docker exec -it clash clashsub add <订阅链接>"
        echo "   docker exec -it clash clashon"
    fi
}

# 停止 clash
stop_clash() {
    echo "😼 停止 Clash 内核..."
    clashoff
    echo "✅ Clash 已停止"
}

# 重启 clash
restart_clash() {
    stop_clash
    sleep 1
    start_clash
}

# 显示状态
show_status() {
    echo "📊 Clash 状态:"
    clashstatus && echo "✅ 运行中" || echo "❌ 未运行"
    echo ""
    echo "📋 订阅列表:"
    clashsub ls 2>/dev/null || echo "  暂无订阅"
}

# 保持容器运行
keep_alive() {
    echo ""
    echo "😼 Clash 已就绪,容器保持运行..."
    echo "💡 提示: 使用 docker exec -it clash bash 可进入容器"
    echo ""

    # 保持容器运行
    tail -f /root/clashctl/resources/mihomo.log 2>/dev/null || \
    tail -f /dev/null
}

# 主函数
main() {
    case "$1" in
        start)
            show_welcome
            ensure_docker_config
            init_config
            start_clash
            keep_alive
            ;;
        stop)
            stop_clash
            ;;
        restart)
            restart_clash
            keep_alive
            ;;
        status)
            show_status
            ;;
        bash|sh)
            exec /bin/bash
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|status|bash}"
            echo "  start   - 启动 Clash (默认)"
            echo "  stop    - 停止 Clash"
            echo "  restart - 重启 Clash"
            echo "  status  - 查看状态"
            echo "  bash    - 进入容器 Shell"
            exit 1
            ;;
    esac
}

main "$@"
