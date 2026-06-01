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

# Patch: NULL-Werte in formatNumber und formatValue abfangen
# bchpool liefert kein diff/accepted/rejected/bestshare
RUN sed -i \
  's/export function formatNumber(num: number | bigint | string): string {/export function formatNumber(num: number | bigint | string | null | undefined): string {\n  if (num === null || num === undefined) return "N\/A";/' \
  utils/helpers.ts

# Patch: formatValue in PoolStatsDisplay für null absichern
RUN sed -i \
  's/return formatNumber(value);/if (value === null || value === undefined) return "N\/A";\n      return formatNumber(value);/' \
  components/PoolStatsDisplay.tsx

COPY .env.production .env

RUN pnpm install --no-frozen-lockfile
RUN pnpm build

# --- Runtime ---
FROM node:20-bookworm-slim

RUN npm install -g pnpm

WORKDIR /app
COPY --from=builder /app /app

# Cron für periodische DB-Updates
RUN apt-get update && apt-get install -y --no-install-recommends \
    cron \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
