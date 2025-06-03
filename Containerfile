FROM ubuntu:latest AS builder

RUN mkdir -p /mnt/src

RUN apt update && apt install -yq make

COPY . /mnt/src

RUN cd /mnt/src && make prefix=/opt/dsyz install

FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade && apt install -yq \
    git \
    golang-go \
    qemu-system-x86 \
    qemu-utils \
    make \
    gcc \
    build-essential \
    --no-install-recommends && \
    apt clean && \
    apt dist-clean

COPY --from=builder /opt/dsyz /opt/dsyz

RUN mkdir -p /var/opt/lib/dsyz

WORKDIR /var/opt/lib/dsyz

RUN /opt/dsyz/bin/dsyz -p

ENTRYPOINT ["/opt/dsyz/bin/dsyz"]
