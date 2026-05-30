# ============================================================
#  bch-rpc-explorer – Dockerfile
#  Self-hosted BCH Block Explorer, datenbankfrei, via RPC
#  Quelle: https://github.com/tajorey/bch-rpc-explorer
# ============================================================

# --- Build-Stage ---
FROM node:20-bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone --depth=1 https://github.com/tajorey/bch-rpc-explorer.git .

# Produktions-Abhängigkeiten installieren
RUN npm ci --omit=dev

# --- Runtime-Stage ---
FROM node:20-bookworm-slim

WORKDIR /app

# Nur App-Code + node_modules aus Builder übernehmen
COPY --from=builder /app /app

# Dedizierter Non-Root User
RUN useradd -r -m -d /app -s /bin/sh explorer \
    && chown -R explorer:explorer /app
USER explorer

# Web-UI Port
EXPOSE 3002

CMD ["node", "bin/www"]
