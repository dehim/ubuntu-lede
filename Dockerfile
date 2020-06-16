FROM ubuntu:16.04 as builder

ENV DEBIAN_FRONTEND noninteractive

COPY files /

RUN apt-get update \
    && mkdir -p /home/openwrt/target \
    && echo 'abc' > /home/openwrt/target/test.txt

FROM ubuntu:16.04

LABEL maintainer "dehim"

#避免安装时弹出对话框
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y supervisor openssh-server openssl vim tzdata git sudo xz-utils \
               build-essential \
    && echo 'root:root' |chpasswd \
    && cp -f /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
    && mv /bin/sh /bin/sh_bak \
    && ln -s /bin/bash /bin/sh \
    && mkdir -p /var/run/sshd \
    && mkdir -p /etc/supervisor/conf.d \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /shareVolume_demo/config/ssh \
    && ssh-keygen -t dsa -f /shareVolume_demo/config/ssh/id_dsa -N "" \
    && ssh-keygen -t rsa -f /shareVolume_demo/config/ssh/id_rsa -N "" \
    && ssh-keygen -t ecdsa -f /shareVolume_demo/config/ssh/id_ecdsa -N "" \
    && ssh-keygen -t ed25519 -f /shareVolume_demo/config/ssh/id_ed25519 -N "" \
    && chmod -R 777 /usr/src/ \
    && sed -ri 's/^#   StrictHostKeyChecking\s+.*/    StrictHostKeyChecking no/' /etc/ssh/ssh_config \
    && sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && cp -f /etc/ssh/ssh_config /etc/ssh/ssh_config_demo \
    && cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config_demo \
    && sed -i 's@#   IdentityFile ~/.ssh/id_rsa@   IdentityFile \/shareVolume\/config\/ssh\/id_rsa@' /etc/ssh/ssh_config \
    && sed -i 's@#   IdentityFile ~/.ssh/id_dsa@   IdentityFile \/shareVolume\/config\/ssh\/id_dsa@' /etc/ssh/ssh_config \
    && sed -i 's@#   IdentityFile ~/.ssh/id_ecdsa@   IdentityFile \/shareVolume\/config\/ssh\/id_ecdsa@' /etc/ssh/ssh_config \
    && sed -i 's@#   IdentityFile ~/.ssh/id_ed25519@   IdentityFile \/shareVolume\/config\/ssh\/id_ed25519@' /etc/ssh/ssh_config \
    && sed -i 's@HostKey \/etc\/ssh\/ssh_host_rsa_key@HostKey \/shareVolume\/config\/ssh\/id_rsa@' /etc/ssh/sshd_config \
    && sed -i 's@HostKey \/etc\/ssh\/ssh_host_dsa_key@HostKey \/shareVolume\/config\/ssh\/id_dsa@' /etc/ssh/sshd_config \
    && sed -i 's@HostKey \/etc\/ssh\/ssh_host_ecdsa_key@HostKey \/shareVolume\/config\/ssh\/id_ecdsa@' /etc/ssh/sshd_config \
    && sed -i 's@HostKey \/etc\/ssh\/ssh_host_ed25519_key@HostKey \/shareVolume\/config\/ssh\/id_ed25519@' /etc/ssh/sshd_config \
    && sed -i 's@#   IdentityFile ~/.ssh/id_rsa@   IdentityFile \/shareVolume_demo\/config\/ssh\/id_rsa@' /etc/ssh/ssh_config \
    && sed -i 's@#   IdentityFile ~/.ssh/id_dsa@   IdentityFile \/shareVolume_demo\/config\/ssh\/id_dsa@' /etc/ssh/ssh_config \
    && sed -i 's@#   IdentityFile ~/.ssh/id_ecdsa@   IdentityFile \/shareVolume_demo\/config\/ssh\/id_ecdsa@' /etc/ssh/ssh_config \
    && sed -i 's@#   IdentityFile ~/.ssh/id_ed25519@   IdentityFile \/shareVolume_demo\/config\/ssh\/id_ed25519@' /etc/ssh/ssh_config \
    && sed -i 's@HostKey \/etc\/ssh\/ssh_host_rsa_key@HostKey \/shareVolume_demo\/config\/ssh\/id_rsa@' /etc/ssh/sshd_config_demo \
    && sed -i 's@HostKey \/etc\/ssh\/ssh_host_dsa_key@HostKey \/shareVolume_demo\/config\/ssh\/id_dsa@' /etc/ssh/sshd_config_demo \
    && sed -i 's@HostKey \/etc\/ssh\/ssh_host_ecdsa_key@HostKey \/shareVolume_demo\/config\/ssh\/id_ecdsa@' /etc/ssh/sshd_config_demo \
    && sed -i 's@HostKey \/etc\/ssh\/ssh_host_ed25519_key@HostKey \/shareVolume_demo\/config\/ssh\/id_ed25519@' /etc/ssh/sshd_config_demo \
    && echo "alias rm='rm -i'" >> ~/.bashrc \
    && echo "alias cp='cp -i'" >> ~/.bashrc \
    && echo "set mouse=c" > ~/.vimrc \
    && echo "if test -f .bashrc; then \nsource .bashrc \nfi " > ~/.bash_profile \
    && rm -f /home/www/.vimrc /home/www/.bashrc \
    && cp -rf ~/.vimrc /home/www/.vimrc \
    && cp -rf ~/.bashrc /home/www/.bashrc \
    && chown www:www /home/www/.vimrc \
    && chown www:www /home/www/.bashrc \
    && chown -R www:www /shareVolume_demo/config/ssh \
    && chmod 600 /shareVolume_demo/config/ssh/* \
    && chmod 644 /shareVolume_demo/config/ssh/*.pub \
    && mv /etc/ssh/*_demo /shareVolume_demo/config/ssh/ \
    && cp -rf ~/.bashrc /.bashrc \
    && cp -rf ~/.bash_profile /.bash_profile \
    && echo "[supervisord] \nnodaemon = true \nuser = root \n" > /shareVolume_demo/config/supervisor/default.ini \
    && echo "[program:sshd] \ncommand = /usr/sbin/sshd -D \nautostart = true \nautorestart = true \n" >> /shareVolume_demo/config/supervisor/sshd.ini.bak 

COPY files/etc/supervisord.conf /etc/
COPY --from=builder /home/openwrt /shareVolume_demo/

VOLUME ["/shareVolume"]

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

# PORT
EXPOSE 22