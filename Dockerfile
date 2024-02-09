FROM dehim/ubuntu-novnc:3.10.12.8 as builder

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
                         && mv /home/www/lede/.config /home/www/ \
                         && mv /home/www/lede/bin/targets /home/www/ \
                         && rm -rf /home/www/lede \
                         && cd /home/www/ \
                         && tar -cvzf lede-$(date +'%Y%m%d%H%M%S').tar.gz .config targets/ \
                         " 

FROM dehim/ubuntu-novnc:3.10.12.8
COPY --from=builder /home/www/lede-*.tar.gz /shareVolume_demo/
