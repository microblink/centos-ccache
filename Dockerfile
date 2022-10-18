FROM amazonlinux:2 as builder

ARG CCACHE_VERSION=4.7
ARG CMAKE_VERSION=3.24.2

# install build dependencies
RUN yum -y install gcc-c++ make tar gzip

ARG BUILDPLATFORM
RUN echo "BUILDPLATFORM is ${BUILDPLATFORM}"

# download and install CMake
RUN cd /home && \
    if [ "$BUILDPLATFORM" == "linux/arm64" ]; then arch=aarch64; else arch=x86_64; fi && \
    curl -o cmake.tar.gz -L https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-${arch}.tar.gz && \
    tar xf cmake.tar.gz && \
    mv cmake-${CMAKE_VERSION}-linux-${arch} cmake

# setup environment variables
ENV PATH="/home/cmake/bin:${PATH}"

# build ccache from source
RUN pushd /home && \
    curl -o ccache.tar.gz -L https://github.com/ccache/ccache/releases/download/v${CCACHE_VERSION}/ccache-${CCACHE_VERSION}.tar.gz  && \
    tar xf ccache.tar.gz    && \
    mkdir build && \
    pushd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DZSTD_FROM_INTERNET=ON -DREDIS_STORAGE_BACKEND=OFF ../ccache-${CCACHE_VERSION} && \
    make -j $(nproc) && \
    make install

FROM amazonlinux:2
COPY --from=builder /usr/local /usr/local/
