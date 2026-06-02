# ============================================================
#  ckstats – Dockerfile
#  Next.js Mining-Dashboard für ckpool
#  Quelle: https://github.com/mrv777/ckstats
# ============================================================

FROM node:20-bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone --depth=1 https://github.com/mrv777/ckstats.git .

# pnpm installieren
RUN npm install -g pnpm

# Patch: NULL-Werte abfangen (bchpool liefert kein diff/accepted/rejected/bestshare)
COPY patch.js /tmp/patch.js
RUN node /tmp/patch.js

COPY .env.production .env

RUN pnpm install --no-frozen-lockfile
RUN pnpm build

# --- Runtime ---
FROM node:20-bookworm-slim

RUN npm install -g pnpm

WORKDIR /app
COPY --from=builder /app /app

# Symlink für node, damit cron es findet
RUN ln -s /usr/local/bin/node /usr/bin/node 2>/dev/null || true

# Cron für periodische DB-Updates
RUN apt-get update && apt-get install -y --no-install-recommends \
    cron \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
