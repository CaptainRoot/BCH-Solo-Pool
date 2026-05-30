# ============================================================
#  Bitcoin Cash Node (BCHN) – Dockerfile
#  Baut BCHN v29.0.0 vollständig aus dem offiziellen GitLab-
#  Quellcode. Kein Drittanbieter-Image, maximale Kontrolle.
#
#  Quelle: https://gitlab.com/bitcoin-cash-node/bitcoin-cash-node
#  Build-System: CMake + Ninja (autotools seit v29 entfernt)
#  Wallet-Support: deaktiviert (nicht nötig fürs Mining)
# ============================================================

# --- Stage 1: Build ---
FROM debian:bookworm-slim AS builder

# Build-Abhängigkeiten laut offizieller BCHN-Doku (build-unix-deb.md)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    ninja-build \
    python3 \
    pkg-config \
    ca-certificates \
    libboost-chrono-dev \
    libboost-filesystem-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libevent-dev \
    libssl-dev \
    libzmq3-dev \
    libgmp-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# BCHN Quellcode von offiziellem GitLab klonen
ARG BCHN_VERSION=v29.0.0
WORKDIR /src
RUN git clone --depth=1 --branch ${BCHN_VERSION} \
    https://gitlab.com/bitcoin-cash-node/bitcoin-cash-node.git .

# Build-Verzeichnis anlegen und kompilieren
# -DBUILD_BITCOIN_WALLET=OFF  → kein Wallet nötig für Mining
# -DBUILD_BITCOIN_QT=OFF      → kein GUI
# -DBUILD_BITCOIN_SEEDER=OFF  → kein Seeder
# -DENABLE_MAN=OFF            → keine Man-Pages
# -DENABLE_UPNP=OFF           → kein UPnP
# -DENABLE_NATPMP=OFF         → kein NAT-PMP
RUN mkdir build && cd build && \
    cmake -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_BITCOIN_WALLET=OFF \
      -DBUILD_BITCOIN_QT=OFF \
      -DBUILD_BITCOIN_SEEDER=OFF \
      -DENABLE_MAN=OFF \
      -DENABLE_UPNP=OFF \
      -DENABLE_NATPMP=OFF \
      -DBUILD_BITCOIN_ZMQ=ON \
    && ninja -j$(nproc) bitcoind bitcoin-cli \
    && strip src/bitcoind src/bitcoin-cli

# --- Stage 2: Runtime (minimales Image) ---
FROM debian:bookworm-slim

# Nur Runtime-Abhängigkeiten
RUN apt-get update && apt-get install -y --no-install-recommends \
    libboost-chrono1.81.0 \
    libboost-filesystem1.81.0 \
    libboost-thread1.81.0 \
    libevent-2.1-7 \
    libssl3 \
    libzmq5 \
    libgmp10 \
    && rm -rf /var/lib/apt/lists/*

# Binaries aus Build-Stage kopieren
COPY --from=builder /src/build/src/bitcoind  /usr/local/bin/bitcoind
COPY --from=builder /src/build/src/bitcoin-cli /usr/local/bin/bitcoin-cli

# Dedizierter User für den Node-Prozess (kein Root)
RUN useradd -r -m -d /data -s /bin/bash bchn
USER bchn

# Datenverzeichnis (Blockchain)
VOLUME ["/data"]

# P2P-Port: BCH-Netzwerk
# RPC-Port wird NICHT exponiert (nur intern per Docker-Netzwerk)
EXPOSE 8333

ENTRYPOINT ["bitcoind"]
CMD ["-datadir=/data", "-printtoconsole"]
