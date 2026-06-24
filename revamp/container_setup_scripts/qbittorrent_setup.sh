#!/bin/bash
# setup_qbittorrent.sh
# Bootstraps host directories and initial config for Dockerized qBittorrent

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