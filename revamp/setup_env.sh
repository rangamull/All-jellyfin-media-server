#!/bin/bash
# setup_env.sh

ENV_FILE=".env"

# Only generate if the file doesn't exist to prevent overwriting keys
echo "--> Detecting host system user and group IDs..."

# Extract the current user's UID and GID dynamically
LOCAL_UID=$(id -u)
LOCAL_GID=$(id -g)

echo "    Detected User ID  (LOCAL_UID): $LOCAL_UID"
echo "    Detected Group ID (LOCAL_GID): $LOCAL_GID"

# Optional safety check: Ensure we aren't accidentally trying to run as root (0)
if [ "$LOCAL_UID" -eq 0 ] || [ "$LOCAL_GID" -eq 0 ]; then
    echo "    [WARNING]: You are running this script as root (UID/GID 0)."
    echo "    It is highly recommended to run this as your standard non-root user."
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "--> Generating permanent API keys..."
    
    # Generate 32-character hex strings
    SONARR_KEY=$(openssl rand -hex 16)
    RADARR_KEY=$(openssl rand -hex 16)
    PROWLARR_KEY=$(openssl rand -hex 16)

    cat <<EOF > "$ENV_FILE"
# Shared variables
COMMON_PATH=/home/jelly/Documents
TZ=Europe/London

# Persistent API Keys
SONARR_API_KEY=$SONARR_KEY
RADARR_API_KEY=$RADARR_KEY
PROWLARR_API_KEY=$PROWLARR_KEY

# User and Group IDs for container permissions
LOCAL_UID=$LOCAL_UID
LOCAL_GID=$LOCAL_GID
EOF
    echo "    Created .env file with generated keys."
else
    echo "    .env file already exists. Skipping."
fi
