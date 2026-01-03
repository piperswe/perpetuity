FROM debian:trixie
# install commonly build-depended-on packages to speed up builds
RUN sed -i 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y build-essential nodejs npm openssh-client \
    && apt-get build-dep -y glibc coreutils wget curl
