FROM debian:jessie

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils \
 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure apt-utils \
 && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        automake \
        cmake \
        curl \
        fakeroot \
        g++ \
        git \
        make \
        runit \
        sudo \
        xz-utils \
 && DEBIAN_FRONTEND=noninteractive apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/*

# Here is where we hardcode the toolchain decision.
ENV HOST=arm-linux-gnueabihf \
    TOOLCHAIN=arm-rpi-4.9.3-linux-gnueabihf \
    RPXC_ROOT=/rpxc

WORKDIR $RPXC_ROOT
RUN curl -L https://github.com/raspberrypi/tools/tarball/master \
  | tar --wildcards --strip-components 3 -xzf - "*/arm-bcm2708/$TOOLCHAIN/"

ENV ARCH=arm \
    CROSS_COMPILE=$RPXC_ROOT/bin/$HOST- \
    PATH=$RPXC_ROOT/bin:$PATH \
    QEMU_PATH=/usr/bin/qemu-arm-static \
    QEMU_EXECVE=1 \
    SYSROOT=$RPXC_ROOT/sysroot

WORKDIR $SYSROOT
RUN curl -L https://github.com/sdhibit/docker-rpi-raspbian/raw/master/raspbian.2015.05.05.tar.xz \
    | tar -xJf - \
 && curl -L https://github.com/multiarch/qemu-user-static/releases/download/v2.9.1-1/qemu-arm-static.tar.gz \
    | tar -zxf - \
    && mv -v qemu-arm-static $SYSROOT/$QEMU_PATH \
 && chmod +x $SYSROOT/$QEMU_PATH \
 && mkdir -p $SYSROOT/build \
 && chroot $SYSROOT $QEMU_PATH /bin/sh -c '\
        apt-get update \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils \
        && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure apt-utils \
        && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y \
                libc6-dev \
                symlinks \
                libboost1.55-all-dev \
                libssl-dev \
                libjansson-dev \
        && symlinks -cors / \
        && DEBIAN_FRONTEND=noninteractive apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf /tmp/*'

COPY image/ /

WORKDIR /build
ENTRYPOINT [ "/rpxc/entrypoint.sh" ]

