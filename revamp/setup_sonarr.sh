#!/bin/bash
# setup_sonarr.sh

source .env

SONARR_URL="http://localhost:8989/api/v3/downloadclient"

echo "--> Waiting for Sonarr to become responsive..."
until curl -s --fail "http://localhost:8989/ping" > /dev/null; do
    sleep 2
done

echo "--> Adding qBittorrent to Sonarr..."
curl -s -X POST "$SONARR_URL" \
  -H "X-Api-Key: $SONARR_API_KEY" \
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
      { "name": "port", "value": 8081 },
      { "name": "username", "value": "admin" },
      { "name": "password", "value": "rangamull" },
      { "name": "tvCategory", "value": "tv-sonarr" },
      { "name": "initialState", "value": 0 }
    ]
  }' > /dev/null

echo "    qBittorrent linked to Sonarr successfully."