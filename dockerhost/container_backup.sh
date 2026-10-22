#!/bin/bash
set -euo pipefail

# -----------------------------------------
# Config
# -----------------------------------------
LOG="/var/log/docker-backup.log"
DATE="$(date '+%Y-%m-%d %H:%M:%S')"
BACKUP_DEST="xxxx@nest:/mnt/bighole/repos/dockerhost/dockers"   # change to your actual backup destination
SRC_VOLUMES="/srv/vault/dockers/"          # path to your Docker volumes

echo "=== Backup start $DATE ===" >> "$LOG"

# -----------------------------------------
# Containers classification
# -----------------------------------------

# 1️⃣ STOP DB containers first
STOP_CONTAINERS=(
  tandori-db_recipes-1
  victoria-metrics
  graylog-mongo
  photoprism-mariadb
)

# 2️⃣ PAUSE app containers that depend on DB
PAUSE_CONTAINERS=(
  tandori-web_recipes-1
  graylog
  graylog-elasticsearch
  photoprism
)

# 3️⃣ PAUSE SQLite-based apps (optional, safer)
PAUSE_SQLITE=(
  radarr
  sonarr
  lidarr
  prowlarr
  bazarr
  Grocy
  ezbookkeeping
  trilium-trilium-1
  grafana
)

# 4️⃣ LIVE rsync (config-only, no need to pause)
LIVE_CONTAINERS=(
  cadvisor
  homarr
  Vert
  bentopdf
  dockhand
  IT-tools
  apprise
  mailrise
  flaresolverr
  tdarr
  node-exporter
  qbittorrentvpn
)

# -----------------------------------------
# Functions
# -----------------------------------------
stop_containers() {
  for c in "$@"; do
    echo "Stopping $c ..." >> "$LOG"
    docker stop "$c" >> "$LOG" 2>&1 || echo "Failed to stop $c" >> "$LOG"
  done
}

start_containers() {
  for c in "$@"; do
    echo "Starting $c ..." >> "$LOG"
    docker start "$c" >> "$LOG" 2>&1 || echo "Failed to start $c" >> "$LOG"
  done
}

pause_containers() {
  for c in "$@"; do
    echo "Pausing $c ..." >> "$LOG"
    docker pause "$c" >> "$LOG" 2>&1 || echo "Failed to pause $c" >> "$LOG"
  done
}

unpause_containers() {
  for c in "$@"; do
    echo "Unpausing $c ..." >> "$LOG"
    docker unpause "$c" >> "$LOG" 2>&1 || echo "Failed to unpause $c" >> "$LOG"
  done
}

# -----------------------------------------
# Backup sequence
# -----------------------------------------

echo "Stopping DB containers..." >> "$LOG"
stop_containers "${STOP_CONTAINERS[@]}"

echo "Pausing dependent apps..." >> "$LOG"
pause_containers "${PAUSE_CONTAINERS[@]}"

echo "Pausing SQLite apps..." >> "$LOG"
pause_containers "${PAUSE_SQLITE[@]}"

echo "Starting rsync..." >> "$LOG"
rsync -avh --delete "$SRC_VOLUMES/" "$BACKUP_DEST/" >> "$LOG" 2>&1

echo "Unpausing SQLite apps..." >> "$LOG"
unpause_containers "${PAUSE_SQLITE[@]}"

echo "Unpausing dependent apps..." >> "$LOG"
unpause_containers "${PAUSE_CONTAINERS[@]}"

echo "Starting DB containers..." >> "$LOG"
start_containers "${STOP_CONTAINERS[@]}"

echo "=== Backup completed $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG"
