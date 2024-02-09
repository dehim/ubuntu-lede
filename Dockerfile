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
                         && mv /home/www/lede/.config /home/www/config \
                         && mv /home/www/lede/bin/targets /home/www/ \
                         && rm -rf /home/www/lede \
                         && cd /home \
                         && tar cvzf lede.tar.gz /home/www/ \
                         && rm /home/www/config \
                         && rm -rf /home/www/targets \
                         " 

FROM dehim/ubuntu-novnc:3.10.12.8
COPY --from=builder /home/www /shareVolume_demo/openwrt
