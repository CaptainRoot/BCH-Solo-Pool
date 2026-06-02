#!/bin/sh
# Startet Cron-Jobs für DB-Updates + Next.js Server

# Node + pnpm Pfade
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
PNPM=$(which pnpm)
NODE=$(which node)

# Umgebungsvariablen für Cron sichern
env | grep -E "^(DB_|NEXTAUTH_|API_URL)" > /etc/cron-env

# Crontab
cat > /etc/cron.d/ckstats << CRON
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

* * * * * root . /etc/cron-env; cd /app && $PNPM seed >> /var/log/ckstats-seed.log 2>&1
* * * * * root . /etc/cron-env; cd /app && $PNPM update-users >> /var/log/ckstats-users.log 2>&1
5 */2 * * * root . /etc/cron-env; cd /app && $PNPM cleanup >> /var/log/ckstats-cleanup.log 2>&1
CRON

chmod 0644 /etc/cron.d/ckstats

# Migration beim ersten Start
cd /app && $PNPM migration:run 2>/dev/null || true

# Cron starten
cron

# Next.js Server starten
exec $PNPM start
