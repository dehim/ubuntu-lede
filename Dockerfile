FROM dehim/ubuntu-lede:1.1.9 as builder

COPY files /

RUN chmod 777 /tmp \
    && apt-get update \
    && su openwrt -l -c "cd /home/openwrt \
                         && git clone https://github.com/coolsnowwolf/lede \
                         && cd /home/openwrt/lede/ \
                         && echo 'src-git helloworld https://github.com/fw876/helloworld' >> /home/openwrt/lede/feeds.conf.default \
                         && ./scripts/feeds update -a \
                         && ./scripts/feeds install -a \
                         && cp /tmp/config.2021.10.01 /home/openwrt/lede/.config \
                         && make -j1 download V=s \
                         && make -j1 V=s \
                         && rm -rf ./tmp \
                         && mv /home/openwrt/lede/.config /home/openwrt/config.2021.10.01 \
                         && mv /home/openwrt/lede/bin/targets /home/openwrt/ \
                         && rm -rf /home/openwrt/lede \
                         " 

FROM ubuntu:20.04

LABEL maintainer "dehim"

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

COPY --from=builder /home/openwrt /shareVolume_demo/openwrt

CMD ["supervisord", "-n", "-c",  "/etc/supervisord.conf"]