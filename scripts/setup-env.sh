#!/bin/bash

# Environment setup for Unturned Dedicated Server

# Set default values if not provided
export SERVER_NAME=${SERVER_NAME:-"MyUnturnedServer"}
export SERVER_PASSWORD=${SERVER_PASSWORD:-""}
export MAX_PLAYERS=${MAX_PLAYERS:-24}
export SERVER_PORT=${SERVER_PORT:-27015}
export QUERY_PORT=${QUERY_PORT:-27016}
export MAP=${MAP:-"PEI"}
export DIFFICULTY=${DIFFICULTY:-"Normal"}
export MODE=${MODE:-"Survival"}
export PERSPECTIVE=${PERSPECTIVE:-"Both"}
export TIMEOUT=${TIMEOUT:-300}
export CYCLE_TIME=${CYCLE_TIME:-3600}
export WELCOME_MESSAGE=${WELCOME_MESSAGE:-"Welcome to my Unturned server!"}
export RULES=${RULES:-"No cheating, be respectful"}
export PVP=${PVP:-true}
export SYNC_MAX_ZOMBIES_NAV=${SYNC_MAX_ZOMBIES_NAV:-60}
export SYNC_MAX_ZOMBIES_POWER=${SYNC_MAX_ZOMBIES_POWER:-50}
export OWNER_ID=${OWNER_ID:-""}
export ADMIN_IDS=${ADMIN_IDS:-""}
export WORKSHOP_FILE_IDS=${WORKSHOP_FILE_IDS:-""}
export VALIDATE_EOS=${VALIDATE_EOS:-true}
export BATTLEYE=${BATTLEYE:-true}
export CHEATS=${CHEATS:-false}
export HIDE_ADMINS=${HIDE_ADMINS:-false}
export ALLOW_LOBBY_CONNECT=${ALLOW_LOBBY_CONNECT:-true}
export VANILLA_BANNING=${VANILLA_BANNING:-true}
export TICK_RATE=${TICK_RATE:-50}

# Server directories
export SERVER_DIR="/home/steam/unturned-server"
export SERVER_INSTANCE_DIR="$SERVER_DIR/Servers/$SERVER_NAME"

# Function to update Config.json with environment variables
setup_config_json() {
    local config_file="$SERVER_INSTANCE_DIR/Config.json"
    
    if [ ! -f "$config_file" ]; then
        # Copy default config if it doesn't exist
        cp /home/steam/config/Config.json "$config_file" 2>/dev/null || true
    fi
    
    if [ -f "$config_file" ]; then
        echo "Updating Config.json with environment variables..."
        
        # Use sed to update configuration values
        sed -i "s/\"Port\": [0-9]*/\"Port\": $SERVER_PORT/g" "$config_file"
        sed -i "s/\"Name\": \"[^\"]*\"/\"Name\": \"$SERVER_NAME\"/g" "$config_file"
        sed -i "s/\"Password\": \"[^\"]*\"/\"Password\": \"$SERVER_PASSWORD\"/g" "$config_file"
        sed -i "s/\"Max_Players\": [0-9]*/\"Max_Players\": $MAX_PLAYERS/g" "$config_file"
        sed -i "s/\"Welcome_Message\": \"[^\"]*\"/\"Welcome_Message\": \"$WELCOME_MESSAGE\"/g" "$config_file"
        sed -i "s/\"Rules\": \"[^\"]*\"/\"Rules\": \"$RULES\"/g" "$config_file"
        sed -i "s/\"Map\": \"[^\"]*\"/\"Map\": \"$MAP\"/g" "$config_file"
        sed -i "s/\"Difficulty\": \"[^\"]*\"/\"Difficulty\": \"$DIFFICULTY\"/g" "$config_file"
        sed -i "s/\"Mode\": \"[^\"]*\"/\"Mode\": \"$MODE\"/g" "$config_file"
        sed -i "s/\"Perspective\": \"[^\"]*\"/\"Perspective\": \"$PERSPECTIVE\"/g" "$config_file"
        sed -i "s/\"Timeout\": [0-9]*/\"Timeout\": $TIMEOUT/g" "$config_file"
        sed -i "s/\"PvP\": [a-z]*/\"PvP\": $PVP/g" "$config_file"
        sed -i "s/\"BattlEye\": [a-z]*/\"BattlEye\": $BATTLEYE/g" "$config_file"
        sed -i "s/\"Cheats\": [a-z]*/\"Cheats\": $CHEATS/g" "$config_file"
        sed -i "s/\"Hide_Admins\": [a-z]*/\"Hide_Admins\": $HIDE_ADMINS/g" "$config_file"
        sed -i "s/\"Allow_Lobby_Connect\": [a-z]*/\"Allow_Lobby_Connect\": $ALLOW_LOBBY_CONNECT/g" "$config_file"
        sed -i "s/\"Validate_EOS\": [a-z]*/\"Validate_EOS\": $VALIDATE_EOS/g" "$config_file"
        sed -i "s/\"VanillaBanning\": [a-z]*/\"VanillaBanning\": $VANILLA_BANNING/g" "$config_file"
        sed -i "s/\"Tick_Rate\": [0-9]*/\"Tick_Rate\": $TICK_RATE/g" "$config_file"
        sed -i "s/\"Max_Zombies_Nav\": [0-9]*/\"Max_Zombies_Nav\": $SYNC_MAX_ZOMBIES_NAV/g" "$config_file"
        sed -i "s/\"Max_Zombies_Power\": [0-9]*/\"Max_Zombies_Power\": $SYNC_MAX_ZOMBIES_POWER/g" "$config_file"
    fi
}

# Function to setup workshop items
setup_workshop_items() {
    if [ ! -z "$WORKSHOP_FILE_IDS" ]; then
        echo "Setting up Workshop items: $WORKSHOP_FILE_IDS"
        
        # Create WorkshopDownloadConfig.json
        local workshop_config="$SERVER_INSTANCE_DIR/WorkshopDownloadConfig.json"
        cat > "$workshop_config" << EOF
{
  "File_IDs": [
    $(echo "$WORKSHOP_FILE_IDS" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')
  ],
  "Ignore_Children_File_IDs": [],
  "Query_Cache_Max_Age_Seconds": 600,
  "Max_Query_Retries": 2,
  "Use_Cached_Downloads": true,
  "Should_Monitor_Updates": true,
  "Shutdown_Update_Detected_Timer": 600,
  "Shutdown_Update_Detected_Message": "Workshop file update detected, shutdown in: {0}"
}
EOF
    fi
}

# Function to setup admin permissions
setup_admins() {
    if [ ! -z "$OWNER_ID" ]; then
        echo "Setting up owner: $OWNER_ID"
        echo "$OWNER_ID" > "$SERVER_INSTANCE_DIR/Cloud/Owner.txt"
    fi
    
    if [ ! -z "$ADMIN_IDS" ]; then
        echo "Setting up admins: $ADMIN_IDS"
        echo "$ADMIN_IDS" | tr ',' '\n' > "$SERVER_INSTANCE_DIR/Cloud/Admins.txt"
    fi
}

# Setup admins when this script is sourced
setup_admins