FROM bitnami/minideb:buster

RUN apt-get update && \
    apt-get -y install make automake autoconf libtool flex bison      \
        pkg-config libssl-dev libxml2-dev python-dev libaio-dev       \
        libibverbs-dev librdmacm-dev libreadline-dev liblvm2-dev      \
        libglib2.0-dev liburcu-dev libcmocka-dev libsqlite3-dev       \
        libacl1-dev git-core libtirpc-dev curl wget go-dep libnfs-dev \
        rsync

RUN mkdir -p /source /build
RUN git clone https://github.com/gluster/glusterfs.git /source
RUN cd /source && git checkout 'v7.6'

WORKDIR /source
RUN sed -i -E 's/AM_INIT_AUTOMAKE\(\[(.+)\]\)/AM_INIT_AUTOMAKE([\1 subdir-objects])/' ./configure.ac
RUN ./autogen.sh
RUN ./configure --disable-fuse-client --disable-syslog --prefix=""
RUN make -j$(nproc)

RUN DESTDIR="/build" make install

RUN wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz && \
    tar -xvf go1.13.3.linux-amd64.tar.gz && \
    mv go /usr/local

ENV GOROOT=/usr/local/go GOPATH=/root/go
RUN export PATH=$GOPATH/bin:$GOROOT/bin:$PATH ; \
    go get github.com/alecthomas/gometalinter ; \
    gometalinter --install --update ; \
    mkdir -p $GOPATH/src/github.com/gluster ; \
    cd $GOPATH/src/github.com/gluster ; \
    git clone https://github.com/gluster/gluster-prometheus.git

RUN export PATH=$GOPATH/bin:$GOROOT/bin:$PATH ; \
    cd $GOPATH/src/github.com/gluster/gluster-prometheus ; \
    PREFIX=/ make

RUN export PATH=$GOPATH/bin:$GOROOT/bin:$PATH ; \
    cd $GOPATH/src/github.com/gluster/gluster-prometheus ; \
    PREFIX=/exporter make install ; \
    rsync -vr /exporter/ /build/

COPY exporter.toml /build/etc/gluster-exporter/gluster-exporter.toml
#COPY run.sh /build

FROM bitnami/minideb:buster

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.0.0.1/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

COPY --from=0 /build .

RUN echo "deb http://deb.debian.org/debian unstable main" >> /etc/apt/sources.list; \
    install_packages libtirpc3 libreadline7 libxml2 kmod \
    procps liburcu6 libibverbs1 librdmacm1 xfsprogs/unstable libnfs12 \
    thin-provisioning-tools python3 udev lvm2 e2fsprogs; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    ln -sv /sbin/lvm /usr/sbin/lvm; \
    ln -s /bin/true /sbin/systemctl

EXPOSE 111 24007 24008 24100 38465-38467 49152-60999

ENV GLUSTERD_OPTIONS="" LOG_LEVEL="INFO"

ADD services.d /etc/services.d
ADD cont-init.d /etc/cont-init.d

ENTRYPOINT ["/init"]
CMD ["sh", "-c", "/sbin/glusterd -N --log-file=- --log-level=$LOG_LEVEL $GLUSTERD_OPTIONS"]
