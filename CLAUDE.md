# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个 Linux 下一键安装和配置 Clash 代理内核的 Shell 脚本项目。支持 `mihomo` 和 `clash` 两种内核,兼容多种 Linux 发行版和容器化环境。

**核心特性**:
- 自动检测系统架构、初始化系统和端口占用
- 支持订阅管理和 Mixin 配置合并
- 提供 Web 控制台和命令行管理工具
- 兼容 systemd、SysVinit、OpenRC、runit 等多种 init 系统
- 支持普通用户和 root 用户环境

## 项目结构

```
.
├── install.sh              # 主安装脚本
├── uninstall.sh            # 卸载脚本
├── .env                    # 配置文件(安装参数、版本号等)
├── scripts/
│   ├── preflight.sh        # 安装前准备逻辑(依赖检测、架构识别、init系统检测)
│   ├── cmd/
│   │   ├── clashctl.sh     # 核心命令实现(clashon/clashoff/clashsub等)
│   │   ├── common.sh       # 通用工具函数(配置管理、下载、验证)
│   │   └── clashctl.fish   # Fish shell 自动补全
│   └── init/               # 各类 init 系统的服务配置模板
│       ├── systemd.sh      # systemd service 模板
│       ├── SysVinit.sh     # SysVinit script 模板
│       ├── OpenRC.sh       # OpenRC script 模板
│       └── runit.sh        # runit script 模板
└── resources/
    ├── mixin.yaml          # Mixin 配置模板(用户自定义配置)
    ├── config.yaml         # 默认订阅配置模板
    ├── profiles.yaml       # 订阅元数据存储
    ├── profiles/           # 订阅配置存储目录
    └── zip/                # 依赖二进制文件存储目录(内核、yq、subconverter)
```

## 核心架构设计

### 1. 配置三层架构

项目使用三层配置系统,通过 `yq` 进行深度合并:

- **config.yaml** (base): 原始订阅配置,从订阅链接下载或本地文件
- **mixin.yaml** (override): 用户自定义配置,优先级最高
- **runtime.yaml** (runtime): 运行时配置,由前两者合并生成,实际加载的配置

**合并逻辑** (scripts/cmd/clashctl.sh:187-253):
- 使用 `yq eval-all` 进行深度合并
- Mixin 中的 `rules`、`proxies`、`proxy-groups` 支持 prefix/suffix/override 三种操作
- `rules`: 前置插入 → 原始规则 → 后置插入
- `proxies/proxy-groups`: 根据 `name` 匹配覆盖,未匹配的保留,最后追加 suffix

### 2. Placeholder 模式

使用占位符模式实现跨 init 系统的兼容:

**安装阶段** (scripts/preflight.sh:296-330):
- 在 init 脚本模板中使用 placeholder (如 `placeholder_start`, `placeholder_log`)
- 安装时根据检测到的 init 类型,用实际命令替换 placeholder

**运行阶段** (scripts/cmd/clashctl.sh):
- clashctl.sh 中的 placeholder 函数(如 `placeholder_start`)在安装时被替换为具体命令
- 实现了与底层 init 系统解耦

支持的 init 系统检测逻辑 (scripts/preflight.sh:178-226):
- 通过 `readlink /proc/1/exe` 检测 init 类型
- 容器环境(docker/k8s/lxc)强制使用 nohup
- 非 root 用户强制使用 nohup

### 3. 依赖管理

项目依赖三个核心工具,在 `_prepare_zip` 阶段下载 (scripts/preflight.sh:56-82):

- **内核**: mihomo 或 clash,根据 CPU 架构和特性检测(SSE4.2/AVX2)选择版本
- **yq**: YAML 配置处理工具,用于配置合并和验证
- **subconverter**: 订阅转换服务,当原始订阅验证失败时自动调用

架构检测逻辑 (scripts/preflight.sh:92-131):
- x86_64: 检测 CPU 特性(SSE4.2/AVX2)选择 v1/v2/v3 版本
- ARM: 区分 armv7 和 arm64
- 其他架构: 需手动下载到 resources/zip/ 目录

## 常用开发任务

### 本地测试安装

```bash
# 测试安装(使用默认 .env 配置)
sudo bash install.sh

# 指定内核和订阅
sudo bash install.sh mihomo "http://your-subscription-url"

# 普通用户安装(会使用 nohup 模式)
bash install.sh
```

### 卸载

```bash
bash uninstall.sh
```

### 修改配置后测试

```bash
# 编辑 Mixin 配置
clashmixin -e

# 查看运行时配置
clashmixin -r

# 重启内核应用新配置
clashoff && clashon
```

### 调试订阅问题

```bash
# 查看订阅日志
clashsub log

# 查看原始订阅配置
cat ~/clashctl/resources/config.yaml

# 查看运行时配置
cat ~/clashctl/resources/runtime.yaml

# 查看内核日志
clashlog
```

### Shell 脚本开发规范

项目使用 `.shellcheckrc` 配置,已禁用以下警告:
- `SC1091`: 无法跟随 source 文件(由于动态路径)
- `SC2155`: 未引用的命令替换(在赋值时常见)
- `SC2296`: 参数展开中的全局变量
- `SC2153`: 可能的变量拼写错误

**重要**:
- 所有 shell 脚本必须以 `#!/usr/bin/env bash` 开头
- 使用 2 空格缩进(遵循 .editorconfig)
- 函数命名: 公开函数用 `function name`, 内部函数用 `_name`
- 变量命名: 全局变量大写(`CLASH_BASE_DIR`),局部变量小写(`local config`)

### 添加新的 init 系统支持

1. 在 `scripts/init/` 创建新模板文件
2. 在 `scripts/preflight.sh:_detect_init` 添加 case 分支
3. 定义 service_* 数组变量(start/stop/status/en/disable等)
4. 在安装时会自动替换 placeholder

## 关键文件说明

### scripts/preflight.sh (397 行)
安装前准备的核心逻辑:
- `_valid()`: 环境验证(依赖、路径、shell)
- `_parse_args()`: 解析命令行参数
- `_prepare_zip()`: 下载和验证依赖二进制
- `_detect_init()`: 检测 init 系统并配置服务管理命令
- `_install_service()`: 安装服务文件并替换 placeholder
- `_apply_rc()`: 配置 shell 环境变量(.bashrc/.zshrc)

### scripts/cmd/clashctl.sh (727 行)
核心命令实现:
- `clashon/clashoff`: 启停代理,自动设置系统代理环境变量
- `clashstatus`: 检查内核运行状态
- `clashui`: 显示 Web 控制台访问信息
- `clashsecret`: 管理 Web 访问密钥
- `clashmixin`: 查看/编辑 Mixin 配置
- `clashupgrade`: 升级内核(通过内核 API)
- `clashtun`: 管理 TUN 模式(透明代理)
- `clashsub`: 订阅管理(add/ls/del/use/update)
- `_merge_config()`: 配置合并的核心逻辑

### scripts/cmd/common.sh (233 行)
通用工具函数:
- `_valid_config()`: 验证 YAML 配置有效性(调用内核 -t 参数)
- `_download_config()`: 下载订阅,失败时自动尝试 subconverter 转换
- `_start_convert/_stop_convert`: 启动/停止 subconverter 服务
- 端口管理: `_is_port_used()`, `_get_random_port()`
- 网络工具: `_get_bind_addr()`, `_get_local_ip()`, `_detect_ext_addr()`

### .env 文件
安装配置文件,主要变量:
- `KERNEL_NAME`: 选择内核(mihomo/clash)
- `CLASH_BASE_DIR`: 安装路径(默认 ~/clashctl)
- `CLASH_CONFIG_URL`: 订阅链接
- `CLASH_SUB_UA`: 下载订阅时的 User-Agent
- `VERSION_*`: 各组件的版本号
- `URL_GH_PROXY`: GitHub 加速代理

## 故障排查指南

### 内核启动失败
1. 查看内核日志: `clashlog` 或 `sudo journalctl -u mihomo`
2. 验证配置: 检查 `runtime.yaml` 是否有效
3. 检查端口: 使用 `clashmixin -r` 查看端口是否冲突
4. 查看订阅日志: `clashsub log`

### 订阅转换失败
1. 检查 subconverter 日志: `~/clashctl/bin/subconverter/latest.log`
2. 手动测试订阅: `curl -A "clash-verge/v2.4.0" "订阅链接"`
3. 查看转换后的配置: `cat ~/clashctl/resources/temp.yaml`

### Web 控制台无法访问
1. 检查密钥: `clashsecret` 查看当前密钥
2. 检查端口: `ss -tunl | grep 9090`
3. 检查防火墙: 确保放行 external-controller 端口
4. 测试本地访问: `curl http://127.0.0.1:9090/ui`

## 版本管理

各组件版本在 `.env` 中定义:
- `VERSION_MIHOMO`: mihomo 内核版本(支持 v1/v2/v3 架构)
- `VERSION_YQ`: yq 工具版本
- `VERSION_SUBCONVERTER`: subconverter 版本

升级组件:
1. 修改 `.env` 中的版本号
2. 运行 `bash uninstall.sh` 卸载
3. 运行 `bash install.sh` 重新安装

## 特殊注意事项

### 安全相关
- Web 控制台默认监听 `0.0.0.0:9090`,建议设置 `secret` 密钥
- 开启 `allow-lan` 时务必配置 `authentication`
- TUN 模式需要 CAP_NET_ADMIN 能力(已在服务文件中配置)

### 容器环境
- Docker/K8s 环境会自动降级为 nohup 模式
- TUN 模式需要 `--cap-add=NET_ADMIN` 特权
- 建议排除 `docker0`/`podman0` 接口以避免容器间访问问题

### 端口管理
- 默认 mixed-port: 7890
- 默认 external-controller: 9090
- 默认 DNS: 1053
- 端口冲突时会自动随机分配可用端口
