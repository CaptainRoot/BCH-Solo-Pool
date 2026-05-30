#!/bin/sh
# Setzt Eigentümer auf /data (Volume beim ersten Start root-owned),
# wechselt dann zu bchn und startet bitcoind.
chown -R bchn:bchn /data
exec gosu bchn bitcoind "$@"
