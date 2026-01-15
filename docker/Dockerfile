# 构建上下文为项目根目录,从 docker 目录构建
# 使用命令: docker build -f docker/Dockerfile .
FROM ubuntu:22.04

# 设置环境变量,避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV CLASH_BASE_DIR=/root/clashctl
ENV CLASH_DOCKER_MODE=1
ENV KERNEL_NAME=mihomo

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    xz-utils \
    unzip \
    iproute2 \
    net-tools \
    kmod \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /tmp/clash-install

# 复制项目文件
COPY . .

# 安装 clash（Docker 环境会自动跳过交互式配置）
RUN bash install.sh

# 清理临时文件
RUN rm -rf /tmp/clash-install

# 创建数据卷用于持久化配置
VOLUME ["/root/clashctl/resources"]

# 暴露常用端口
# 7890: mixed-port (HTTP/SOCKS5)
# 9090: external-controller (Web UI)
# 1053: DNS
EXPOSE 7890 9090 1053

# 添加 TUN 模式需要的权限说明
LABEL "com.clash.description"="Clash proxy for Linux"
LABEL "com.clash.capabilities"="NET_ADMIN NET_RAW"

# 设置入口点
COPY docker/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 安装wrapper脚本，使docker exec能直接使用clashctl命令
COPY docker/clashctl-wrapper.sh /usr/local/bin/clashctl-wrapper
RUN chmod +x /usr/local/bin/clashctl-wrapper

# 创建便捷命令软链接
RUN ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashctl && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashon && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashoff && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashstatus && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashsub && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashui && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashsecret && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashmixin && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashtun && \
    ln -sf /usr/local/bin/clashctl-wrapper /usr/local/bin/clashlog

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
