FROM docker.io/blackdesk/base:latest AS builder

RUN mkdir -p /mnt/src

RUN apt update && apt install -yq make

COPY . /mnt/src

RUN cd /mnt/src && make prefix=/opt/dsyz install

FROM docker.io/blackdesk/base:latest

RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh bc
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh bison
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh build-essential
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh ca-certificates
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh debootstrap
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh flex
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh gcc
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh git
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh golang-go
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh libelf-dev
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh libncurses-dev
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh libssl-dev
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh make
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh openssh-client
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh qemu-system-x86
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh qemu-utils
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh sudo
RUN "$BLACKDESK_CONTAINERFILES_SCRIPTS"/apt-install.sh zstd

COPY --from=builder /opt/dsyz /opt/dsyz

RUN mkdir -p /var/opt/lib/dsyz

WORKDIR /var/opt/lib/dsyz

ENTRYPOINT ["/opt/dsyz/bin/dsyz"]
