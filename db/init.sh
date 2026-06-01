#!/bin/bash
# Läuft beim ersten Start von PostgreSQL automatisch
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER ckstats WITH PASSWORD 'AENDERN_SICHERES_PASSWORT_HIER';
    CREATE DATABASE ckstats OWNER ckstats;
    GRANT ALL PRIVILEGES ON DATABASE ckstats TO ckstats;
EOSQL
