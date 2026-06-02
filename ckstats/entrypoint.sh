#!/bin/sh
# Startet Cron-Jobs für DB-Updates + Next.js Server

PNPM=$(which pnpm)

# Umgebungsvariablen für Cron sichern
env | grep -E "^(DB_|NEXTAUTH_|API_URL|NODE)" > /etc/cron-env

# Crontab
cat > /etc/cron.d/ckstats << 'CRON'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

* * * * * root . /etc/cron-env; cd /app && pnpm seed >> /var/log/ckstats-seed.log 2>&1
* * * * * root . /etc/cron-env; cd /app && pnpm update-users >> /var/log/ckstats-users.log 2>&1
5 */2 * * * root . /etc/cron-env; cd /app && pnpm cleanup >> /var/log/ckstats-cleanup.log 2>&1
CRON

chmod 0644 /etc/cron.d/ckstats

# Migration beim ersten Start
cd /app && pnpm migration:run 2>/dev/null || true

# Cron starten
cron

# Next.js Server starten
exec pnpm start
