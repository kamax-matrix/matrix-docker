FROM debian:stretch-slim

VOLUME /app/etc
VOLUME /app/var
VOLUME /app/log

ENV SYNAPSE_CONF_PATH /app/etc
ENV SYNAPSE_CONF_FILE homeserver.yaml
ENV SYNAPSE_CONF_D_DIR conf.d
ENV SYNAPSE_DATA_PATH /app/var
ENV SYNAPSE_LOG_PATH /app/log

ENV SYNAPSE_DEFAULT_CONF_PATH /etc/default/synapse

ENTRYPOINT ["/bin/bash"]
CMD ["/app/synapse"]

# use --build-arg REBUILD=$(date) to invalidate the cache and upgrade all
# packages
ARG REBUILD=1
RUN set -ex \
    && mkdir /uploads \
    && export DEBIAN_FRONTEND=noninteractive \
    && mkdir -p /var/cache/apt/archives \
    && touch /var/cache/apt/archives/lock \
    && apt-get clean \
    && apt-get update -y -q --fix-missing \
    && apt-get upgrade -y \
    && buildDeps=' \
        file \
        gcc \
        git \
        libevent-dev \
        libffi-dev \
        libgnutls28-dev \
        libjpeg62-turbo-dev \
        libsasl2-dev \
        libssl-dev \
        libtool \
        libxml2-dev \
        libxslt1-dev \
        linux-headers-amd64 \
        make \
        python-dev \
        python-setuptools \
        zlib1g-dev \
    ' \
    && apt-get install -y --no-install-recommends \
        $buildDeps \
        bash \
        coreutils \
        libevent-2.0-5 \
        libffi6 \
        libjpeg62-turbo \
        libssl1.1 \
        libtool \
        libxml2 \
        libxslt1.1 \
        pwgen \
        python \
        python-pip \
        python-psycopg2 \
        python-virtualenv \
        zlib1g \
    ; \
    pip install --upgrade wheel ;\
    pip install --upgrade pyopenssl ;\
    pip install --upgrade enum34 ;\
    pip install --upgrade ipaddress ;\
    pip install --upgrade lxml \
    ; \
    pip install --upgrade --process-dependency-links https://github.com/matrix-org/synapse/tarball/v0.27.4 \
    ; \
    apt-get autoremove -y $buildDeps ;\
    apt-get autoremove -y ;\
    rm -rf /var/lib/apt/* /var/cache/apt/*

COPY app.sh /app/synapse
COPY etc /etc/default/synapse
