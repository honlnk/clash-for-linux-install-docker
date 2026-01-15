#!/usr/bin/env bash
# Wrapper脚本 for docker exec
# 加载clashctl命令并执行用户输入的命令

. /root/clashctl/scripts/cmd/clashctl.sh

# 执行用户传入的命令
"$@"
