# syntax=docker/dockerfile:1-labs

FROM ubuntu:latest AS builder

RUN mkdir -p /mnt/src

RUN apt update && apt install -yq make

COPY . /mnt/src

RUN cd /mnt/src && make prefix=/opt/dsyz install

FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade && apt install -yq --no-install-recommends \
    bc \
    bison \
    build-essential \
    ca-certificates \
    debootstrap \
    flex \
    gcc \
    git \
    golang-go \
    libelf-dev \
    libncurses-dev \
    libssl-dev \
    make \
    openssh-client \
    qemu-system-x86 \
    qemu-utils \
    sudo \
    && \
    apt clean && \
    apt dist-clean

COPY --from=builder /opt/dsyz /opt/dsyz

RUN mkdir -p /var/opt/lib/dsyz

WORKDIR /var/opt/lib/dsyz

ENTRYPOINT ["/opt/dsyz/bin/dsyz"]
