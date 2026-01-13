# 构建上下文为项目根目录,从 docker 目录构建
# 使用命令: docker build -f docker/Dockerfile .
FROM ubuntu:22.04

# 设置环境变量,避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV CLASH_BASE_DIR=/opt/clashctl
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

# 创建 Docker 专用的 .env 文件，设置正确的安装路径
RUN echo 'KERNEL_NAME=mihomo\n\
CLASH_BASE_DIR=/opt/clashctl\n\
CLASH_CONFIG_URL=\n\
CLASH_SUB_UA=clash-verge/v2.4.0\n\
INIT_TYPE=\n\
ZIP_UI=resources/zip/dist.zip\n\
URL_GH_PROXY=https://gh-proxy.org\n\
VERSION_MIHOMO=v1.19.17\n\
VERSION_YQ=v4.49.2\n\
VERSION_SUBCONVERTER=v0.9.0' > .env

# 安装 clash（Docker 环境：自动跳过订阅交互）
RUN bash install.sh < /dev/null || echo "Installation completed with warnings"

# 清理临时文件
RUN rm -rf /tmp/clash-install

# 创建数据卷用于持久化配置
VOLUME ["/opt/clashctl/resources"]

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

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
