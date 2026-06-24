#!/bin/bash
# setup_env.sh

ENV_FILE=".env1"

# Only generate if the file doesn't exist to prevent overwriting keys
if [ ! -f "$ENV_FILE" ]; then
    echo "--> Generating permanent API keys..."
    
    # Generate 32-character hex strings
    SONARR_KEY=$(openssl rand -hex 16)
    RADARR_KEY=$(openssl rand -hex 16)
    PROWLARR_KEY=$(openssl rand -hex 16)

    cat <<EOF > "$ENV_FILE"
# Shared variables
COMMON_PATH=/your/chosen/path
TZ=Europe/London

# Persistent API Keys
SONARR_API_KEY=$SONARR_KEY
RADARR_API_KEY=$RADARR_KEY
PROWLARR_API_KEY=$PROWLARR_KEY
EOF
    echo "    Created .env file with generated keys."
else
    echo "    .env file already exists. Skipping."
fi