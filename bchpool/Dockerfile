# ============================================================
#  bchpool – Dockerfile
#  ckpool-Fork für Bitcoin Cash (dagurval/bchpool)
#  Baut aus Quellcode, kein Drittanbieter-Image
# ============================================================

FROM debian:bullseye-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ca-certificates \
    yasm \
    autoconf \
    automake \
    libtool \
    libjansson-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth=1 https://github.com/dagurval/bchpool.git .

RUN autoreconf -fi \
    && CFLAGS="-fcommon" ./configure --without-ckdb \
    && make -j$(nproc) \
    && strip src/ckpool

# --- Runtime ---
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libjansson4 \
    libcurl4 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/src/ckpool /usr/local/bin/ckpool

RUN mkdir -p /var/log/ckpool /etc/ckpool
VOLUME ["/var/log/ckpool"]

EXPOSE 3333

ENTRYPOINT ["/usr/local/bin/ckpool"]
