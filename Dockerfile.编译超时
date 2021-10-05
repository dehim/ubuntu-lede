FROM dehim/ubuntu-lede:1.1.0 as builder

COPY files /

RUN chmod 777 /tmp \
    && su www -l -c "cd /home/www \
                         && git clone https://github.com/coolsnowwolf/lede \
                         && cd /home/www/lede/ \
                         && echo 'src-git helloworld https://github.com/fw876/helloworld' >> /home/www/lede/feeds.conf.default \
                         && ./scripts/feeds update -a \
                         && ./scripts/feeds install -a \
                         && cp /tmp/config.2021.10.01 /home/www/lede/.config \
                         && make -j1 download V=s \
                         && make -j1 V=s \
                         && rm -rf ./tmp \
                         && mv /home/www/lede/.config /home/www/config.2021.10.01 \
                         && mv /home/www/lede/bin/targets /home/www \
                         && rm -rf /home/www/lede \
                         " 

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y supervisor \
    && mkdir -p /etc/supervisor/conf.d \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /shareVolume_demo/config/ssh \
    && mkdir -p /shareVolume_demo/config/supervisor/ \
    && echo "alias rm='rm -i'" >> ~/.bashrc \
    && echo "alias cp='cp -i'" >> ~/.bashrc \
    && echo "set mouse=c" > ~/.vimrc \
    && echo "if test -f .bashrc; then \nsource .bashrc \nfi " > ~/.bash_profile \
    && cp -rf ~/.bashrc /.bashrc \
    && cp -rf ~/.bash_profile /.bash_profile \
    && sed -i 's@files = /etc/supervisor/conf.d/\*.conf@; files = /etc/supervisor/conf.d/\*.conf@' /etc/supervisor/supervisord.conf \
    && echo 'files = /shareVolume/config/supervisor/\*.ini' >> /etc/supervisor/supervisord.conf \
    && mv /etc/supervisor/supervisord.conf /etc/supervisord.conf \
    && mkdir -p /shareVolume_demo/config/supervisor/ \
    && echo "[supervisord] \nnodaemon = true \nuser = root \n" > /shareVolume_demo/config/supervisor/default.ini \
    && echo "[program:sshd] \ncommand = /usr/sbin/sshd -D \nautostart = true \nautorestart = true \n" >> /shareVolume_demo/config/supervisor/sshd.ini.bak 

COPY --from=builder /home/www /shareVolume_demo/

VOLUME ["/shareVolume"]

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

EXPOSE 22