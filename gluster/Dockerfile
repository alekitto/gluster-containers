FROM bitnami/minideb:buster

RUN apt-get update && \
    apt-get -y install make automake autoconf libtool flex bison      \
        pkg-config libssl-dev libxml2-dev python-dev libaio-dev       \
        libibverbs-dev librdmacm-dev libreadline-dev liblvm2-dev      \
        libglib2.0-dev liburcu-dev libcmocka-dev libsqlite3-dev       \
        libacl1-dev git-core libtirpc-dev

RUN mkdir -p /source /build
RUN git clone https://github.com/gluster/glusterfs.git /source
RUN cd /source && git checkout 'v7.1'

WORKDIR /source
RUN ./autogen.sh
RUN ./configure --disable-fuse-client --disable-syslog --prefix=""
RUN make -j$(nproc)

ENV DESTDIR="/build"
RUN make install

COPY run.sh /build

FROM bitnami/minideb:buster

COPY --from=0 /build .

RUN apt-get update; \
    apt-get -y install libtirpc3 libreadline7 libxml2 kmod \
    procps liburcu6 libibverbs1 librdmacm1 xfsprogs \
    thin-provisioning-tools python3 udev lvm2; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    ln -s /bin/true /sbin/systemctl

EXPOSE 111 24007 24008 38465-38467 49152-60999

CMD ["/run.sh"]
