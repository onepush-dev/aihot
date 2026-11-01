#!/bin/sh
# Runs as root so the Railway volume can be chowned, then drops to node.
set -e
mkdir -p "$AIHOT_DATA_DIR" && chown -R node:node "$AIHOT_DATA_DIR"
export WEB_PORT="${PORT:-3000}"
[ -n "$SITE_URL" ] || export SITE_URL="http://localhost:${WEB_PORT}"
cd /app
run() { su node -s /bin/sh -c "$*"; }
echo "[aihot] migrate + seed"
until run "node scripts/migrate.ts"; do echo "[aihot] db not ready, retrying"; sleep 3; done
run "node scripts/seed.ts"
su node -s /bin/sh -c "exec node apps/api/src/main.ts" & API=$!
su node -s /bin/sh -c "exec node apps/worker/src/main.ts" & WRK=$!
su node -s /bin/sh -c "exec node apps/web/server.ts" & WEB=$!
trap 'kill -TERM $API $WRK $WEB 2>/dev/null' TERM INT
while kill -0 $API 2>/dev/null && kill -0 $WRK 2>/dev/null && kill -0 $WEB 2>/dev/null; do sleep 5; done
echo "[aihot] a process exited; stopping"; kill -TERM $API $WRK $WEB 2>/dev/null; wait; exit 1
