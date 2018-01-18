FROM monstrenyatko/rpi-cross-compiler:no_rpxc_stage_1

MAINTAINER Oleg Kovalenko <monstrenyatko@gmail.com>

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libboost1.55-all-dev \
        libssl-dev \
        libjansson-dev \
    && DEBIAN_FRONTEND=noninteractive apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY image/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
