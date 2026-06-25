#!/bin/bash
source .env

# Ensure the COMMON_PATH variable is provided
if [ -z "$COMMON_PATH" ]; then
    echo "ERROR: COMMON_PATH environment variable is not set."
    echo "Usage: export COMMON_PATH=/your/chosen/path && ./setup_qbittorrent.sh"
    exit 1
fi

echo "--> Creating qBittorrent directory structure under $COMMON_PATH..."
mkdir -p "${COMMON_PATH}/configs/qbittorrent/qBittorrent"
mkdir -p "${COMMON_PATH}/qbittorrent/downloads"

echo "--> Seeding initial qBittorrent configuration..."
QBIT_CONF="${COMMON_PATH}/configs/qbittorrent/qBittorrent/qBittorrent.conf"

# Only create the config file if it doesn't already exist to prevent overwriting
if [ ! -f "$QBIT_CONF" ]; then
    cat <<EOF > "$QBIT_CONF"
[BitTorrent]
Session\DefaultSavePath=/data/qbittorrent/downloads
Session\TempPath=/data/qbittorrent/downloads/temp
EOF
    echo "    Created $QBIT_CONF with unified /data paths."
else
    echo "    Configuration file already exists. Skipping creation."
fi

# Set ownership if running containers with specific PUID/PGID (currently 0/root in your compose)
# chown -R 0:0 "${COMMON_PATH}/configs/qbittorrent" "${COMMON_PATH}/qbittorrent"

echo "--> qBittorrent bootstrap complete."

echo "--> Creating Jellyfin configuration and cache directories..."
mkdir -p "${COMMON_PATH}/configs/jellyfin"
mkdir -p "${COMMON_PATH}/jellyfin/cache"

echo "--> Creating shared media directories for Jellyfin to scan..."
# Creating these here ensures Jellyfin doesn't throw errors looking for missing mounts
mkdir -p "${COMMON_PATH}/sonarr/tv"
mkdir -p "${COMMON_PATH}/radarr/movies"

echo "--> Jellyfin bootstrap complete."
echo "    Note: Internal library setup (mapping to /data/sonarr/tv) must be done via the Jellyfin web wizard on first launch."

mkdir -p "${COMMON_PATH}/configs/homarr/appdata"

echo "--> Creating Tdarr config and processing directories..."
mkdir -p "${COMMON_PATH}/configs/tdarr/server"
mkdir -p "${COMMON_PATH}/configs/tdarr/configs"
mkdir -p "${COMMON_PATH}/configs/tdarr/logs"

# The cache folder where video files are held while being transcoded
mkdir -p "${COMMON_PATH}/tdarr/cache"

echo "--> Creating Recyclarr directories..."
mkdir -p "${COMMON_PATH}/configs/recyclarr"

RECYCLARR_CONF="${COMMON_PATH}/configs/recyclarr/recyclarr.yml"

echo "--> Seeding initial Recyclarr configuration with API Keys..."
if [ ! -f "$RECYCLARR_CONF" ]; then
    cat <<EOF > "$RECYCLARR_CONF"
# Recyclarr Configuration (Auto-Generated)
sonarr:
  main_sonarr:
    base_url: http://sonarr:8989
    api_key: $SONARR_API_KEY
    quality_profiles:
      - name: Any

radarr:
  main_radarr:
    base_url: http://radarr:7878
    api_key: $RADARR_API_KEY
    quality_profiles:
      - name: Any
EOF
    echo "    Created $RECYCLARR_CONF linked to Sonarr and Radarr."
else
    echo "    Recyclarr config already exists. Skipping."
fi

echo "--> Recyclarr bootstrap complete."