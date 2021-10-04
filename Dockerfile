FROM ubuntu:18.04 as builder

COPY files /

RUN CONFIG_FILENAME='config.2021.10.01'; \
    apt-get update \
    # 需要额外添加cmake，否则编译报错：Compatibility with CMake < 2.8.12 will be removed from a future version of
    && apt-get install -y apt-utils dialog openssh-server openssl vim tzdata sudo xz-utils iputils-ping supervisor time libjpeg-dev cmake \
                          build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip \
                          zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev \
                          texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler \
                          g++-multilib antlr3 gperf wget curl swig rsync \
    && su www -l -c "cd /home/www \
                         && git clone https://github.com/coolsnowwolf/lede \
                         && cd /home/www/lede/ \
                         && cp /tmp/${CONFIG_FILENAME} /home/www/lede/.config \
                         && echo 'src-git helloworld https://github.com/fw876/helloworld' >> /home/www/lede/feeds.conf.default \
                         && ./scripts/feeds update -a \
                         && ./scripts/feeds install -a \
                         && make -j1 download V=s \
                         && make -j1 V=s \
                         && rm -rf ./tmp \
                         && mv /home/www/lede/.config /home/www/${CONFIG_FILENAME} \
                         && mv /home/www/lede/bin/targets /home/www \
                         && rm -rf /home/www/lede \
                         " 

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y supervisor \
    && mkdir -p /etc/supervisor/conf.d \
    && mkdir -p /var/log/supervisor \
    && sed -i 's@files = /etc/supervisor/conf.d/\*.conf@; files = /etc/supervisor/conf.d/\*.conf@' /etc/supervisor/supervisord.conf \
    && echo 'files = /shareVolume/config/supervisor/\*.ini' >> /etc/supervisor/supervisord.conf \
    && mv /etc/supervisor/supervisord.conf /etc/supervisord.conf \
    && mkdir -p /shareVolume_demo/config/supervisor/ \
    && echo "[supervisord] \nnodaemon = true \nuser = root \n" > /shareVolume_demo/config/supervisor/default.ini 

COPY --from=builder /home/www /shareVolume_demo/www

CMD ["supervisord", "-n", "-c",  "/etc/supervisord.conf"]
