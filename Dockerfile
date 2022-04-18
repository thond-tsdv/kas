# This image builds Yocto 2.1 and 2.2 jobs using the kas tool

FROM debian:jessie-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN echo 'deb http://deb.freexian.com/extended-lts/ jessie main' > /etc/apt/sources.list

ENV LOCALE=en_US.UTF-8
RUN apt-get update && \
    apt-get install --no-install-recommends -y --force-yes locales && \
    sed -i -e "s/# $LOCALE/$LOCALE/" /etc/locale.gen && \
    rm /usr/share/locale/locale.alias && \
    ln -s /etc/locale.alias /usr/share/locale/locale.alias && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    apt-get install --no-install-recommends -y --force-yes \
                       gawk wget git-core diffstat unzip file \
                       texinfo gcc-multilib build-essential \
                       chrpath socat cpio python python3 rsync \
                       tar bzip2 curl dosfstools mtools parted \
                       syslinux tree python3-pip bc python3-yaml \
                       lsb-release python3-setuptools ssh-client \
                       vim less mercurial iproute2 python3-dev \
                       libssl-dev libzmq3-dev python3-zmq && \
    echo 'deb http://deb.debian.org/debian stretch main' >> /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    apt-get install -y --force-yes -f --no-install-recommends --target-release stretch \
            xz-utils groff && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 --output /usr/bin/gosu && chmod +x /usr/bin/gosu

RUN wget -nv -O /usr/bin/oe-git-proxy "http://git.yoctoproject.org/cgit/cgit.cgi/poky/plain/scripts/oe-git-proxy" && \
    chmod +x /usr/bin/oe-git-proxy
ENV GIT_PROXY_COMMAND="oe-git-proxy"
ENV NO_PROXY="*"

COPY . /kas
RUN pip3 --proxy=$http_proxy install typing-extensions==3.6.6 attrs==18.1.0 importlib-metadata==1.5.0 zipp==0.5 importlib-resources==3.0.0 jsonschema==2.5.1 distro==1.1.0
RUN pip3 --proxy=$https_proxy install /kas
RUN pip3 --proxy=$http_proxy install lavacli==0.7
RUN pip3 --proxy=$http_proxy install PySocks awscli==1.18.223

ENV LANG=$LOCALE

ENTRYPOINT ["/kas/docker-entrypoint"]
