#!/usr/bin/env bash
# Build the database from the raw CSV, run every analysis query and redraw the charts.
# Connection settings come from the usual libpq variables (PGHOST, PGPORT, PGUSER).
set -euo pipefail

DB="${PGDATABASE:-lazada_reviews}"
RAW="data/raw/20191002-reviews.csv"

if [[ ! -f "$RAW" ]]; then
    echo "Missing $RAW. See data/README.md for the download step." >&2
    exit 1
fi

createdb "$DB" 2>/dev/null || true
export PGDATABASE="$DB"

psql -q -v ON_ERROR_STOP=1 -f sql/01_schema.sql
psql -q -v ON_ERROR_STOP=1 -c "\copy staging.reviews_raw FROM '$RAW' WITH (FORMAT csv, HEADER true)"
psql -q -v ON_ERROR_STOP=1 -f sql/02_transform.sql
psql -q -v ON_ERROR_STOP=1 -f sql/03_views.sql
psql -q -v ON_ERROR_STOP=1 -f sql/04_item_type.sql

mkdir -p results
for query in sql/analysis/*.sql; do
    psql -q -v ON_ERROR_STOP=1 --csv -f "$query" > "results/$(basename "$query" .sql).csv"
done

python scripts/make_charts.py
