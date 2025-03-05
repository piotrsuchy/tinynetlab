FROM debian:11

ENV FRR_VERSION="10"
ENV LIBYANG_VERSION="2.1.128"
ENV FRR_POOL_VERSION="9"
ENV DEB_VERSION="2"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
	apt-utils \
	autoconf \
	automake \
	autotools-dev \
	bash-completion \
	bison \
	build-essential \
	chrpath \
	cmake \
	curl \
	debhelper \
	devscripts \
	dpkg \
	fakeroot \
	flex \
	fping \
	gawk \
	g++ \
	gcc \
	gettext \
	git \
	git-buildpackage \
	gzip \
	install-info \
	iproute2 \
	iputils-ping \
	jq \
	less \
	libc-ares-dev \
	libc-ares2 \
	libcap-dev \
	libcjson-dev \
	libc6 \
	libelf-dev \
	libelf1 \
	libjson-c-dev \
	libpam-dev \
	libpam0g-dev \
	libpcap0.8 \
	libpcap0.8-dev \
	libpcre2-dev \
	libprotobuf-c-dev \
	libprotoc-dev \
	libpython3-dev \
	libreadline-dev \
	libreadline8 \
	libsnmp-dev \
	libssh-4 \
	libssh-dev \
	libsystemd-dev \
	libtool \
	libunwind8 \
	lldpd \
	logrotate \
	lsof \
	m4 \
	make \
	mtr-tiny \
	nano \
	pkg-config \
	protobuf-c-compiler \
	python3 \
	python3-dev \
	python3-pip \
	python3-pytest \
	python3-sphinx \
	python3-setuptools \
	python3-venv \
	sudo \
	tar \
	tcpdump \
	telnet \
	texinfo \
	vim \
	wget && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*
RUN wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/liby/libyang2/libyang-tools_${LIBYANG_VERSION}-${DEB_VERSION}~deb11u1_all.deb \
    && wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/liby/libyang2/libyang2-dev_${LIBYANG_VERSION}-${DEB_VERSION}~deb11u1_amd64.deb \
    && wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/liby/libyang2/libyang2-tools_${LIBYANG_VERSION}-${DEB_VERSION}~deb11u1_amd64.deb \
    && wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/liby/libyang2/libyang2_${LIBYANG_VERSION}-${DEB_VERSION}~deb11u1_amd64.deb \
    && wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/libr/librtr0/librtr-dbg_0.8.0~deb11u1_amd64.deb \
    && wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/libr/librtr0/librtr-dev_0.8.0~deb11u1_amd64.deb \
    && wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/libr/librtr0/librtr0_0.8.0~deb11u1_amd64.deb \
    && wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/libr/librtr0/rtr-tools-dbg_0.8.0~deb11u1_amd64.deb \
    && wget https://deb.frrouting.org/frr/pool/frr-${FRR_POOL_VERSION}/libr/librtr0/rtr-tools_0.8.0~deb11u1_amd64.deb \
    && dpkg -i libyang2_${LIBYANG_VERSION}-${DEB_VERSION}~deb11u1_amd64.deb \
    && dpkg -i libyang2-tools_${LIBYANG_VERSION}-${DEB_VERSION}~deb11u1_amd64.deb \
    && dpkg -i libyang-tools_${LIBYANG_VERSION}-${DEB_VERSION}~deb11u1_all.deb \
    && dpkg -i libyang2-dev_${LIBYANG_VERSION}-${DEB_VERSION}~deb11u1_amd64.deb \
    && dpkg -i librtr0_0.8.0~deb11u1_amd64.deb \
    && dpkg -i librtr-dbg_0.8.0~deb11u1_amd64.deb \
    && dpkg -i librtr-dev_0.8.0~deb11u1_amd64.deb \
    && dpkg -i rtr-tools_0.8.0~deb11u1_amd64.deb \
    && dpkg -i rtr-tools-dbg_0.8.0~deb11u1_amd64.deb \
    && rm -f *.deb

RUN git clone https://github.com/FRRouting/frr.git && \
    cd frr && \
	git checkout frr-10.3-dev; \
    ./bootstrap.sh && \
    ./configure --prefix=/usr --enable-multipath=64 --localstatedir=/var/run/frr \
                --sysconfdir=/etc/frr --enable-user=root --enable-group=root \
                --enable-vtysh && \
    make && make install && \
    mkdir -p /etc/frr && \
    touch /etc/frr/vtysh.conf

WORKDIR /root/

CMD ["tail", "-f", "/dev/null"]
