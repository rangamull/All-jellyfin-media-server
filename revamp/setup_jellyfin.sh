#!/bin/bash
# setup_jellyfin.sh
# Bootstraps host directories for Dockerized Jellyfin
source .env

# Ensure the COMMON_PATH variable is provided
if [ -z "$COMMON_PATH" ]; then
    echo "ERROR: COMMON_PATH environment variable is not set."
    echo "Usage: export COMMON_PATH=/your/chosen/path && ./setup_jellyfin.sh"
    exit 1
fi

echo "--> Creating Jellyfin configuration and cache directories..."
mkdir -p "${COMMON_PATH}/configs/jellyfin"
mkdir -p "${COMMON_PATH}/jellyfin/cache"

echo "--> Creating shared media directories for Jellyfin to scan..."
# Creating these here ensures Jellyfin doesn't throw errors looking for missing mounts
mkdir -p "${COMMON_PATH}/sonarr/tv"
mkdir -p "${COMMON_PATH}/radarr/movies"

# Set ownership if necessary
# chown -R 0:0 "${COMMON_PATH}/configs/jellyfin" "${COMMON_PATH}/jellyfin"

echo "--> Jellyfin bootstrap complete."
echo "    Note: Internal library setup (mapping to /data/sonarr/tv) must be done via the Jellyfin web wizard on first launch."