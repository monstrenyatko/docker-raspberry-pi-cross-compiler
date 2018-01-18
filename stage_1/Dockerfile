FROM raspbian/jessie

MAINTAINER Oleg Kovalenko <monstrenyatko@gmail.com>

COPY tmp/qemu-arm-static /usr/bin/qemu-arm-static

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure apt-utils \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        automake \
        make \
        cmake \
        wget \
        curl \
        g++ \
        runit \
        xz-utils \
        python-dev \
        libc6-dev \
        libicu-dev \
    && DEBIAN_FRONTEND=noninteractive apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*
