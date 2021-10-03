FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y openssh-server openssl vim tzdata sudo xz-utils \
                          build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev \
                          patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion \
                          flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo \
                          libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool \
                          autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync \

    && addgroup www \
    && useradd -g www -r -m -s /bin/bash www \
    && echo 'www:www' |chpasswd \
    && echo 'root:root' |chpasswd \
    && echo "www ALL=(ALL:ALL) ALL \nwww ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/default \
    && chmod 440 /etc/sudoers.d/default \
    && cp -f /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
    && chmod 777 -R /usr/src \
    && echo "Asia/Shanghai" > /etc/timezone \
    # && dpkg-reconfigure -f noninteractive tzdata \
    # && mv /bin/sh /bin/sh_bak \
    # && ln -s /bin/bash /bin/sh \
    && mkdir -p /var/run/sshd/ \
    && mkdir -p /etc/supervisor/conf.d/ \
    && mkdir -p /var/log/supervisor/ \
    && mkdir -p /shareVolume_demo/config/ssh/ \
    && ssh-keygen -t dsa -f /shareVolume_demo/config/ssh/id_dsa -N "" \
    && ssh-keygen -t rsa -f /shareVolume_demo/config/ssh/id_rsa -N "" \
    && ssh-keygen -t ecdsa -f /shareVolume_demo/config/ssh/id_ecdsa -N "" \
    && ssh-keygen -t ed25519 -f /shareVolume_demo/config/ssh/id_ed25519 -N "" \
    && chmod -R 777 /usr/src/ \
	# 解决 sudo -i 映射不了 X11 问题
    && touch /home/www/.Xauthority \
    && chown www:www /home/www/.Xauthority \
	&& ln -s /home/www/.Xauthority /root/.Xauthority \
    && sed -ri 's/^#   StrictHostKeyChecking\s+.*/    StrictHostKeyChecking no/' /etc/ssh/ssh_config \
    && sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    # 解决 rejected X11 forwarding
    && sed -ri 's/^#X11UseLocalhost\s+.*/X11UseLocalhost no/' /etc/ssh/sshd_config \
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
    && chmod 600 /shareVolume_demo/config/ssh/* \
    && chmod 644 /shareVolume_demo/config/ssh/*.pub \
    && mv /etc/ssh/*_demo /shareVolume_demo/config/ssh/ \
    && cp -rf ~/.bashrc /.bashrc \
    && cp -rf ~/.bash_profile /.bash_profile \
    && mkdir -p /shareVolume_demo/www/ \
    && chown -R www:www /shareVolume_demo/www \
    && sed -i 's@files = /etc/supervisor/conf.d/*.conf@; files = /etc/supervisor/conf.d/*.conf@' /etc/supervisor/supervisord.conf \
    && echo 'files = /shareVolume/config/supervisor/*.ini' > /etc/supervisor/supervisord.conf \
    && mv /etc/supervisor/supervisord.conf /etc/supervisord.conf \
    && echo "[supervisord] \nnodaemon = true \nuser = root \n" > /shareVolume_demo/config/supervisor/default.ini \
    && echo "[program:sshd] \ncommand = /usr/sbin/sshd -D \nautostart = true \nautorestart = true \n" >> /shareVolume_demo/config/supervisor/sshd.ini.bak 

VOLUME ["/shareVolume"]

CMD ["supervisord", "-n", "-c",  "/etc/supervisord.conf"]

# EXPOSE 22