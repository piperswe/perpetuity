FROM debian:trixie
RUN sed -i 's/Types: deb/Types: deb deb-src/g' /etc/apt/sources.list.d/debian.sources \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y build-essential nodejs npm
