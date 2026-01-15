#!/usr/bin/env bash

. scripts/cmd/clashctl.sh
. scripts/preflight.sh

_valid
_parse_args "$@"

_prepare_zip
_detect_init

_okcat "安装内核：$KERNEL_NAME by ${INIT_TYPE}"
_okcat '📦' "安装路径：$CLASH_BASE_DIR"

/bin/cp -rf . "$CLASH_BASE_DIR"
touch "$CLASH_CONFIG_BASE"
_set_envs
_is_regular_sudo && chown -R "$SUDO_USER" "$CLASH_BASE_DIR"

_install_service
_apply_rc

clashsecret "$(_get_random_val)" >/dev/null
clashui
clashsecret

_okcat '🎉' 'enjoy 🎉'

# 检测是否在Docker容器环境中
_is_docker_env() {
    [ -f /.dockerenv ] && return 0
    grep -qa docker /proc/1/cgroup 2>/dev/null && return 0
    [ -n "$CLASH_DOCKER_MODE" ] && return 0
    return 1
}

# Docker环境跳过交互式配置
if _is_docker_env; then
    _okcat '🐳' '检测到Docker环境，跳过交互式配置'
    _okcat '💡' '容器启动后使用以下命令添加订阅：'
    echo '  docker exec -it <container> clashsub add <url>'
    echo '  docker exec -it <container> clashsub use <id>'
else
    clashctl
    _valid_config "$RESOURCES_CONFIG_BASE" && CLASH_CONFIG_URL="file://$CLASH_CONFIG_BASE"
    _quit "clashsub add $CLASH_CONFIG_URL && clashsub use 1"
fi
