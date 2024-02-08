FROM dehim/ubuntu-novnc:3.6.9.2 as builder

COPY files /

RUN chmod 777 /tmp \
    && apt-get update \
    && su www -l -c "cd /home/www \
                         && git clone https://github.com/coolsnowwolf/lede \
                         && cd /home/www/lede/ \
                         && echo 'src-git helloworld https://github.com/fw876/helloworld' >> feeds.conf.default \
                         && ./scripts/feeds update -a \
                         && ./scripts/feeds install -a \
                         && cp /tmp/config /home/www/lede/.config \
                         && make -j1 download V=s \
                         && make -j1 V=s \
                         && rm -rf ./tmp \
                         && mv /home/www/lede/.config /home/www/config \
                         && mv /home/www/lede/bin/targets /home/www/ \
                         && rm -rf /home/www/lede \
                         " 

FROM ubuntu:18.04

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

COPY --from=builder /home/www /shareVolume_demo/openwrt

CMD ["supervisord", "-n", "-c",  "/etc/supervisord.conf"]