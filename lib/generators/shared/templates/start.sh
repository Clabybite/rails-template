#!/bin/bash

ENV=${RAILS_ENV:-development}
ROOT="$(pwd)"
BASE_DIR="$ROOT/redis/$ENV"
mkdir -p "$BASE_DIR/data"

CONFIG_FILE="$BASE_DIR/redis.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "🛠️  Creating Redis config: $CONFIG_FILE"
  cat > "$CONFIG_FILE" <<EOF
port 0
unixsocket $BASE_DIR/redis.sock
unixsocketperm 770
dir $BASE_DIR/data
pidfile $BASE_DIR/redis.pid
dbfilename dump.rdb
databases 1
EOF
fi

echo "🚀 Starting Redis for $ENV"
redis-server "$CONFIG_FILE"