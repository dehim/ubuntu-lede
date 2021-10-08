FROM ubuntu:18.04 as builder

ENV DEBIAN_FRONTEND noninteractive

COPY files /

RUN chmod 777 /tmp \
    && apt-get update \
    && apt-get install -y apt-utils dialog openssh-server openssl vim tzdata sudo xz-utils iputils-ping supervisor time libjpeg-dev xmltoman bison \
                          build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip \
                          zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev \
                          texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler \
                          g++-multilib antlr3 gperf wget curl swig rsync \

# 解决：
#12 8239.8 Package tcpping is missing dependencies for the following libraries:
#12 8239.8 libnet.so.9
#12 8239.8 libpcap.so.1
    && cd /usr/src/ \
    && wget https://github.com/libnet/libnet/archive/refs/tags/v1.2.tar.gz \
    && tar -zxvf v1.2.tar.gz \
    && cd libnet-1.2 \
    && ./autogen.sh \
    && ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu \
    && make \
    && make install \
    && rm -rf /usr/src/* \   

    && cd /usr/src/ \
    && wget http://www.tcpdump.org/release/libpcap-1.10.1.tar.gz \
    && tar -zxvf libpcap-1.10.1.tar.gz \
    && cd libpcap-1.10.1 \
    && ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu \
    && make \
    && make install \
    && rm -rf /usr/src/* \  
                                
    && cp -f /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m openwrt \
    && echo 'openwrt ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/default \
    && chown -R openwrt:openwrt /home/openwrt \

    && sed -i 's@files = /etc/supervisor/conf.d/\*.conf@; files = /etc/supervisor/conf.d/\*.conf@' /etc/supervisor/supervisord.conf \
    && echo 'files = /shareVolume/config/supervisor/\*.ini' >> /etc/supervisor/supervisord.conf \
    && mv /etc/supervisor/supervisord.conf /etc/supervisord.conf \
    && mkdir -p /shareVolume_demo/config/supervisor/ \
    && echo "[supervisord] \nnodaemon = true \nuser = root \n" > /shareVolume_demo/config/supervisor/default.ini \
    && echo "[program:sshd] \ncommand = /usr/sbin/sshd -D \nautostart = true \nautorestart = true \n" >> /shareVolume_demo/config/supervisor/sshd.ini.bak 

COPY --from=builder /home/openwrt /shareVolume_demo/

VOLUME ["/shareVolume"]

CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

EXPOSE 22