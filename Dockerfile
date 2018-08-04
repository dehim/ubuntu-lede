FROM ubuntu:16.04
MAINTAINER admin@hiram.cn

#避免安装过程弹出框
ENV DEBIAN_FRONTEND noninteractive
ENV FORCE_UNSAFE_CONFIGURE 1

RUN apt-get update \
    && apt-get install -y sudo \
    && apt-get install -y curl \
    && apt-get install -y apt-utils \
    && apt-get install -y tzdata \
    && apt-get install -y openssh-server \
    && apt-get install -y dialog \
    && apt-get install -y vim \
    && apt-get install -y iputils-ping \
    && apt-get install -y supervisor \
    && apt-get install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev \
    && rm /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    # remove caches
    # && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd \
    && mkdir -p /etc/supervisor/conf.d \
    && mkdir -p /var/log/supervisor \
    && useradd -m openwrt \
    && echo 'root:root' |chpasswd \
    && echo -e 'www-data  ALL=(ALL:ALL) ALL \nwww-data  ALL=(ALL:ALL) NOPASSWD:ALL \n\nopenwrt ALL=NOPASSWD: ALL' > /etc/sudoers.d/default \
    && chmod 440 /etc/sudoers.d/default \
    && ssh-keygen -q -b 2048 -t rsa  -f /root/.ssh/id_rsa  -N '' \
    && cat /root/.ssh/id_rsa >> /etc/ssh/id_rsa \
    && cat /root/.ssh/id_rsa.pub >> /etc/ssh/id_rsa.pub \
    # && ssh-keygen -q -t ecdsa -f /etc/ssh/id_ecdsa -N '' \
    && sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && sudo -iu openwrt mkdir -p /var/lede \
    && sudo -iu openwrt git clone https://github.com/coolsnowwolf/lede.git /var/lede/ \
    && sudo -iu openwrt /var/lede/scripts/feeds update -a \
    && sudo -iu openwrt /var/lede/scripts/feeds install -a

# 复制文件夹
COPY files /

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisor/supervisord.conf"]

# PORT
EXPOSE 5050 22