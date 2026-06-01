#!/bin/sh
# Startet Cron-Jobs für DB-Updates + Next.js Server

# Crontab anlegen
cat > /etc/cron.d/ckstats << 'CRON'
# Jede Minute: neue Shares und User-Stats einlesen
* * * * * root cd /app && /usr/local/bin/pnpm seed >> /var/log/ckstats-seed.log 2>&1
* * * * * root cd /app && /usr/local/bin/pnpm update-users >> /var/log/ckstats-users.log 2>&1
# Alle 2 Stunden: alte Daten aufräumen
5 */2 * * * root cd /app && /usr/local/bin/pnpm cleanup >> /var/log/ckstats-cleanup.log 2>&1
CRON

chmod 0644 /etc/cron.d/ckstats
cron

# DB-Schema initialisieren (beim ersten Start)
cd /app && pnpm migration:run 2>/dev/null || true

# Next.js Server starten
exec pnpm start
