FROM dehim/ubuntu-lede:1.0.9 as builder

COPY files /

RUN CONFIG_FILENAME='config.2021.10.01'; \
    su www -l -c "cd /home/www \
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

FROM ubuntu:20.04

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
