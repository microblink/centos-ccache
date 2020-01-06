FROM centos:7 as builder

ARG CCACHE_VERSION=3.7.7

# install build dependencies
RUN yum -y install gcc make

# build ccache from source
RUN pushd /home && \
    curl -o ccache.tar.gz -L https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/ccache-${CCACHE_VERSION}.tar.gz  && \
    tar xf ccache.tar.gz    && \
    mkdir build && \
    pushd build && \
    ../ccache-${CCACHE_VERSION}/configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

FROM centos:7
COPY --from=builder /usr/local /usr/local/
