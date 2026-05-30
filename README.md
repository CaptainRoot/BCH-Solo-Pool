# BCH Solo Mining Pool + Block Explorer

Drei Services, alle aus Quellcode gebaut:

| Service    | Port | Beschreibung                        |
|------------|------|-------------------------------------|
| bchn       | 8333 | Bitcoin Cash Full Node (BCHN v29)   |
| bchpool    | 3333 | Stratum V1 – Bitaxe verbindet hier  |
| explorer   | 3002 | BCH Block Explorer Web-UI           |

---

## Verzeichnisstruktur

```
bch-solo-pool/
├── docker-compose.yml
├── bchn/
│   ├── Dockerfile          ← BCHN aus GitLab (CMake/Ninja)
│   └── bitcoin.conf        ← txindex=1 Pflicht für Explorer!
├── bchpool/
│   ├── Dockerfile          ← bchpool aus GitHub (autotools)
│   └── ckpool.conf         ← Stratum-Config + BCH-Adresse
├── explorer/
│   ├── Dockerfile          ← bch-rpc-explorer aus GitHub (Node.js)
│   └── explorer.env        ← Explorer-Konfiguration
└── data/
    ├── bchn/               ← Blockchain-Daten (~230 GB)
    └── bchpool-logs/       ← Stratum-Logs
```

---

## 1. Einmalige Konfiguration

### Sicheres RPC-Passwort generieren
```bash
openssl rand -hex 32
```

Dieses Passwort an VIER Stellen eintragen (müssen identisch sein):
- `bchn/bitcoin.conf`       → `rpcpassword=`
- `bchpool/ckpool.conf`     → `"pass":`
- `explorer/explorer.env`   → `BTCEXP_BITCOIND_PASS=`
- `docker-compose.yml`      → im healthcheck (`-rpcpassword=`)

### BCH-Wallet-Adresse eintragen
In `bchpool/ckpool.conf`:
```json
"btcaddress" : "DEINE_BCH_ADRESSE_HIER"
```

---

## 2. Erster Start

```bash
# Alle drei Images aus Quellcode bauen (~15–25 Min)
docker compose build --no-cache

# Stack starten
docker compose up -d

# Blockchain synchronisieren (mehrere Stunden!)
docker compose logs -f bchn
```

Explorer und bchpool starten automatisch sobald der Node
den Healthcheck besteht.

---

## 3. Bitaxe Gamma konfigurieren

Im Bitaxe-Webinterface (http://<bitaxe-ip>):

| Feld      | Wert                         |
|-----------|------------------------------|
| Pool Host | IP deines Docker-Hosts       |
| Pool Port | 3333                         |
| Username  | deine BCH-Adresse            |
| Password  | x                            |

Nur die rohe IP – kein stratum+tcp:// Präfix!

---

## 4. Explorer aufrufen

```
http://<IP-deines-Docker-Hosts>:3002
```

Funktionen: Blocks, Transaktionen, Adressen, Mempool,
Node-Info (Peers, Sync-Status, Chaininfo).

---

## 5. txindex nachträglich aktivieren

Falls der Node bereits ohne txindex läuft:

```bash
# 1. bitcoin.conf ist bereits auf txindex=1 gesetzt
# 2. Reindex starten (node kurz stoppen)
docker compose stop bchn
docker compose run --rm bchn bitcoind -datadir=/data -reindex &
# Warten bis abgeschlossen (Logs beobachten)
docker compose logs -f bchn
# Dann normal neu starten
docker compose up -d bchn
```

⚠️ Reindex dauert mehrere Stunden!

---

## 6. Überwachung

```bash
# Stratum-Aktivität (Shares, verbundene Miner)
docker compose logs -f bchpool

# Node-Status
docker compose exec bchn bitcoin-cli -datadir=/data getblockchaininfo

# Explorer-Logs
docker compose logs -f explorer

# Block gefunden?
docker compose logs bchpool | grep -i "BLOCK"
```

---

## 7. Einzelne Images upgraden

```bash
# BCHN-Version in docker-compose.yml anpassen:
#   BCHN_VERSION: "v29.1.0"
docker compose build --no-cache bchn
docker compose up -d bchn
```
