# BCH Solo Mining Pool – Lokale Builds

Beide Images (BCHN + bchpool) werden vollständig aus Quellcode gebaut.
Kein Drittanbieter-Image, keine externen Binaries.

## Verzeichnisstruktur

```
bch-solo-pool/
├── docker-compose.yml
├── bchn/
│   ├── Dockerfile          ← BCHN aus GitLab-Quellcode (CMake/Ninja)
│   └── bitcoin.conf        ← RPC-Credentials, Node-Config
├── bchpool/
│   ├── Dockerfile          ← bchpool aus GitHub-Quellcode (autotools)
│   └── ckpool.conf         ← Stratum-Config + BCH-Adresse
└── data/
    ├── bchn/               ← Blockchain-Daten (~230 GB, auto-erstellt)
    └── bchpool-logs/       ← Stratum-Logs (auto-erstellt)
```

---

## 1. Einmalige Konfiguration

### Sicheres RPC-Passwort generieren
```bash
openssl rand -hex 32
```
Diesen Wert an **drei Stellen** eintragen – müssen identisch sein:

- `bchn/bitcoin.conf`    → `rpcpassword=`
- `bchpool/ckpool.conf`  → `"pass":`
- `docker-compose.yml`   → im healthcheck (`-rpcpassword=`)

### BCH-Wallet-Adresse eintragen
In `bchpool/ckpool.conf`:
```json
"btcaddress" : "DEINE_BCH_ADRESSE_HIER"
```
Diese Adresse erhält den vollen Block-Reward direkt in der Coinbase-Transaktion.

---

## 2. Images bauen und starten

```bash
# Beide Images aus Quellcode bauen (~10–20 Min je nach CPU)
docker compose build --no-cache

# Stack starten
docker compose up -d

# Blockchain synchronisieren (mehrere Stunden!)
docker compose logs -f bchn
```

Der Healthcheck auf `bchn` verzögert den Start von `bchpool` automatisch.
`bchpool` startet erst wenn `bitcoin-cli getblockchaininfo` erfolgreich antwortet.

---

## 3. Bitaxe Gamma konfigurieren

Im Bitaxe-Webinterface (http://<bitaxe-ip>):

| Feld        | Wert                            |
|-------------|----------------------------------|
| Pool Host   | IP deines Docker-Hosts           |
| Pool Port   | 3333                             |
| Username    | deine BCH-Adresse                |
| Password    | x                                |

Nur die rohe IP ins Host-Feld – kein stratum+tcp:// Präfix!

---

## 4. Betrieb überwachen

```bash
# Stratum-Verbindungen und Shares
docker compose logs -f bchpool

# BCH Node: Sync-Status
docker compose exec bchn bitcoin-cli -datadir=/data getblockchaininfo

# Aktueller Block
docker compose exec bchn bitcoin-cli -datadir=/data getblockcount

# Block gefunden? Suche in Logs:
docker compose logs bchpool | grep -i "BLOCK"
```

---

## 5. BCHN-Version upgraden

In docker-compose.yml unter `args`:
```yaml
BCHN_VERSION: "v29.1.0"
```
Dann:
```bash
docker compose build --no-cache bchn
docker compose up -d bchn
```

---

## Ports

| Port | Dienst   | Beschreibung                          |
|------|----------|---------------------------------------|
| 3333 | Stratum  | Bitaxe verbindet sich hier            |
| 8333 | BCH P2P  | BCH-Netzwerk (eingehende Peers)       |
| 8332 | RPC      | Intern only – nicht nach außen!       |

## Sicherheitshinweise

- RPC-Port 8332 ist nicht nach außen exponiert (nur Docker-intern).
- BCHN läuft als dedizierter Non-Root User im Container.
- Das RPC-Passwort niemals in git committen.
