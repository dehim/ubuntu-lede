FROM dehim/ubuntu-lede:1.0.0
MAINTAINER dehim

ENV DEBIAN_FRONTEND noninteractive

COPY files /

RUN chown -R openwrt:openwrt /home/openwrt \
    && cd /home/openwrt/lede \
    && su openwrt -l -c "git pull \
                         && ./scripts/feeds update -a \
                         && ./scripts/feeds install -a \
                         && cp -f /home/openwrt/.config .config \
                         && make -j$(getconf _NPROCESSORS_ONLN) download V=s \
                         && make -j$(getconf _NPROCESSORS_ONLN) V=s \
                         && rm -rf ./tmp \
                         " 

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisor/supervisord.conf"]

# PORT
EXPOSE 22