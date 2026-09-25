FROM debian:bookworm-slim

WORKDIR /usr/src/nipe
COPY . .

EXPOSE 9050 9051 9061

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    cpanminus \
    tor \
    iptables \
    iproute2 \
    libssl-dev \
    libnet-ssleay-perl \
    libcrypt-ssleay-perl \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/tor/torrc.d /run/tor /var/run/tor /var/log/tor /var/lib/tor \
 && printf "SocksPort 0.0.0.0:9050\nTransPort 0.0.0.0:9051\nDNSPort 0.0.0.0:9061\n" > /etc/tor/torrc.d/nipe.conf \
 && chown -R debian-tor:debian-tor /run/tor /var/run/tor /var/log/tor /var/lib/tor

RUN cpanm --notest --installdeps .

RUN chmod +x nipe.pl

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -s -f --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip || exit 1

ENTRYPOINT ["/bin/bash"]

