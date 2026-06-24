#!/bin/bash
# setup_bazarr.sh

source .env

echo "--> Seeding initial Bazarr configuration..."
mkdir -p "${COMMON_PATH}/configs/bazarr"
BAZARR_CONF="${COMMON_PATH}/configs/bazarr/config.ini"

# Create the config file to link Radarr and Sonarr natively
if [ ! -f "$BAZARR_CONF" ]; then
    cat <<EOF > "$BAZARR_CONF"
[radarr]
apikey = $RADARR_API_KEY
ip = radarr
port = 7878
base_url = /

[sonarr]
apikey = $SONARR_API_KEY
ip = sonarr
port = 8989
base_url = /
EOF
    echo "    Created $BAZARR_CONF with Sonarr and Radarr API links."
else
    echo "    Bazarr config already exists. Skipping."
fi