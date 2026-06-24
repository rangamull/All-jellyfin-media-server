#!/bin/bash
# setup_radarr.sh

source .env

RADARR_URL="http://localhost:7878/api/v3/downloadclient"

echo "--> Waiting for Radarr to become responsive..."
until curl -s --fail "http://localhost:7878/ping" > /dev/null; do
    sleep 2
done

echo "--> Adding qBittorrent to Radarr..."
curl -s -X POST "$RADARR_URL" \
  -H "X-Api-Key: $RADARR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "enable": true,
    "protocol": "torrent",
    "priority": 1,
    "removeCompletedDownloads": true,
    "removeFailedDownloads": true,
    "name": "qBittorrent",
    "implementation": "QBittorrent",
    "configContract": "QBittorrentSettings",
    "fields": [
      { "name": "host", "value": "qbittorrent" },
      { "name": "port", "value": 8080 },
      { "name": "username", "value": "admin" },
      { "name": "password", "value": "adminadmin" },
      { "name": "movieCategory", "value": "radarr" },
      { "name": "initialState", "value": 0 }
    ]
  }' > /dev/null

echo "    qBittorrent linked to Radarr successfully."