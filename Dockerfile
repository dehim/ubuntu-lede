FROM ubuntu:16.04
MAINTAINER dehim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y sudo curl apt-utils tzdata openssh-server dialog vim iputils-ping supervisor time \
                          build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core \
                          gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget \
    && cp -f /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
    # remove caches
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/lede \
    && mkdir -p /var/run/sshd \
    && mkdir -p /etc/supervisor/conf.d \
    && mkdir -p /var/log/supervisor \
    && useradd -m openwrt \
    && echo 'root:root' |chpasswd \
    && echo 'openwrt ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/default \
    && chmod 440 /etc/sudoers.d/default \
    && ssh-keygen -q -b 2048 -t rsa -f /etc/ssh/id_rsa -N '' \
    && sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
    && echo "[supervisord] \nnodaemon = true \nuser = root \n" > /etc/supervisor/conf.d/default.conf \
    && echo "[program:bash] \ncommand = /bin/bash \nautostart = true \nautorestart = true \n" >> /etc/supervisor/conf.d/default.conf \
    && echo "[program:sshd] \ncommand = /usr/sbin/sshd -D \nautostart = true \nautorestart = true \n" >> /etc/supervisor/conf.d/default.conf 
    # 准备编译

COPY files /

RUN chown -R openwrt:openwrt /home/openwrt \
    && cd /home/openwrt \
    && su openwrt -l -c "git clone https://github.com/coolsnowwolf/lede \
                         && cd /home/openwrt/lede/ \
                         && sed -i 's@#src-git helloworld https://github.com/fw876/helloworld@src-git helloworld https://github.com/fw876/helloworld@' /home/openwrt/lede/feeds.conf.default \
                         && ./scripts/feeds update -a \
                         && ./scripts/feeds install -a \
                         && cp /home/openwrt/.config .config \
                         && make -j$(getconf _NPROCESSORS_ONLN) download V=s \
                         && make -j$(getconf _NPROCESSORS_ONLN) V=s \
                         && rm -rf ./tmp \
                         " 

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisor/supervisord.conf"]

# PORT
EXPOSE 22