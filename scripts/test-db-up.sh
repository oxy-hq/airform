#!/usr/bin/env bash
# Start tier-2 test databases with automatic port selection.
# If the default port is occupied, finds the next free one.
# Writes chosen ports to .test-ports.env (read by tests via dotenv).
set -euo pipefail
cd "$(dirname "$0")/.."

find_free_port() {
  local port=$1
  while lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; do
    echo "  Port $port occupied, trying $((port + 1))..." >&2
    port=$((port + 1))
  done
  echo "$port"
}

PG_PORT=$(find_free_port "${AIRFORM_PG_PORT:-15432}")
CH_HTTP_PORT=$(find_free_port "${AIRFORM_CH_HTTP_PORT:-18123}")
CH_TCP_PORT=$(find_free_port "${AIRFORM_CH_TCP_PORT:-19000}")

cat > .test-ports.env <<EOF
AIRFORM_PG_PORT=$PG_PORT
AIRFORM_CH_HTTP_PORT=$CH_HTTP_PORT
AIRFORM_CH_TCP_PORT=$CH_TCP_PORT
EOF

echo "Ports: pg=$PG_PORT ch_http=$CH_HTTP_PORT ch_tcp=$CH_TCP_PORT"

export AIRFORM_PG_PORT=$PG_PORT
export AIRFORM_CH_HTTP_PORT=$CH_HTTP_PORT
export AIRFORM_CH_TCP_PORT=$CH_TCP_PORT

docker compose -f docker-compose.test.yml up -d "$@"

echo ""
echo "To run tests:  set -a && source .test-ports.env && set +a && cargo test --test dialect_tests -- --include-ignored"
