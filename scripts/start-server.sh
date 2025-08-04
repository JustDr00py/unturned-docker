#!/bin/bash

# Unturned Dedicated Server Startup Script
set -e

echo "Starting Unturned Dedicated Server..."

# Source environment setup
source /home/steam/scripts/setup-env.sh

# Update server if needed
echo "Checking for server updates..."
/home/steam/steamcmd/steamcmd.sh \
    +force_install_dir $SERVER_DIR \
    +login anonymous \
    +app_update 1110390 \
    +quit

# Create server instance directory if it doesn't exist
SERVER_INSTANCE_DIR="$SERVER_DIR/Servers/$SERVER_NAME"
if [ ! -d "$SERVER_INSTANCE_DIR" ]; then
    echo "Creating server instance directory: $SERVER_INSTANCE_DIR"
    mkdir -p "$SERVER_INSTANCE_DIR"
fi

# Copy configuration files
echo "Setting up server configuration..."
if [ -d "/home/steam/config" ]; then
    cp -r /home/steam/config/* "$SERVER_INSTANCE_DIR/" 2>/dev/null || true
fi

# Update Config.json with environment variables
setup_config_json

# Set up workshop items if specified
if [ ! -z "$WORKSHOP_FILE_IDS" ]; then
    setup_workshop_items
fi

# Start the server
echo "Starting Unturned server: $SERVER_NAME"
cd "$SERVER_DIR"

# Use the ServerHelper.sh script to start the server
exec ./ServerHelper.sh "+InternetServer/$SERVER_NAME"