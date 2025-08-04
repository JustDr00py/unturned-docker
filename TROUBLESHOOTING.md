# Troubleshooting Guide

## Permission Errors

### ERROR: Failed to install app '1110390' (Missing file permissions)

This is a common Docker permissions issue. Here are several solutions:

#### Solution 1: Fix Docker Compose (Recommended)
The updated `docker-compose.yml` should handle this automatically, but if you're still having issues:

```bash
# Stop the containers
docker-compose down

# Remove any existing volumes
docker volume prune

# Recreate with proper permissions
docker-compose up -d
```

#### Solution 2: Manual Permission Fix
```bash
# Stop the container
docker-compose down

# Fix permissions on host directories
sudo chown -R 1000:1000 ./server-data
sudo chown -R 1000:1000 ./config
sudo chmod -R 755 ./server-data
sudo chmod -R 755 ./config

# Restart
docker-compose up -d
```

#### Solution 3: Alternative Docker Compose Configuration
If you're still having issues, use this alternative approach:

```yaml
version: '3.8'

services:
  unturned-server:
    image: cm2network/steamcmd:root
    container_name: unturned-dedicated-server
    restart: unless-stopped
    ports:
      - "${SERVER_PORT:-27015}:${SERVER_PORT:-27015}/udp"
      - "${QUERY_PORT:-27016}:${QUERY_PORT:-27016}/udp"
    volumes:
      - unturned-data:/home/steam/unturned-server
      - ./config:/home/steam/config:ro
    environment:
      - PUID=1000
      - PGID=1000
    env_file:
      - .env
    user: "1000:1000"
    command: >
      bash -c "
        # Create directories with proper permissions
        mkdir -p /home/steam/unturned-server &&
        
        # Install/Update Unturned Dedicated Server
        /home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/unturned-server +login anonymous +app_update 1110390 validate +quit &&
        
        # Setup server configuration
        mkdir -p /home/steam/unturned-server/Servers/$$SERVER_NAME &&
        cp -r /home/steam/config/* /home/steam/unturned-server/Servers/$$SERVER_NAME/ 2>/dev/null || true &&
        
        # Start the server
        cd /home/steam/unturned-server &&
        ./ServerHelper.sh +InternetServer/$$SERVER_NAME
      "
    networks:
      - unturned-network

volumes:
  unturned-data:
    driver: local

networks:
  unturned-network:
    driver: bridge
```

#### Solution 4: Using Custom Dockerfile
Create a container with proper user setup:

```dockerfile
FROM cm2network/steamcmd:root

# Create steam user with specific UID/GID
RUN groupadd -g 1000 steam && \
    useradd -u 1000 -g 1000 -m -s /bin/bash steam

# Install dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set up directories with correct ownership
RUN mkdir -p /home/steam/unturned-server && \
    chown -R steam:steam /home/steam

# Copy startup script
COPY --chown=steam:steam scripts/start-server.sh /home/steam/
RUN chmod +x /home/steam/start-server.sh

USER steam
WORKDIR /home/steam

EXPOSE 27015/udp 27016/udp

ENTRYPOINT ["/home/steam/start-server.sh"]
```

Then use this in your docker-compose.yml:
```yaml
services:
  unturned-server:
    build: .
    # ... rest of configuration
```

### Other Common Issues

#### SteamCMD Login Issues
```bash
# Clear Steam credentials
docker exec -it unturned-dedicated-server rm -rf /home/steam/.steam

# Restart container
docker-compose restart unturned-server
```

#### Disk Space Issues
```bash
# Check disk space
df -h

# Clean up Docker
docker system prune -a

# Clean up old containers
docker container prune
```

#### Network Issues
```bash
# Check if ports are in use
netstat -tulpn | grep :27015
netstat -tulpn | grep :27016

# Kill processes using the ports if needed
sudo fuser -k 27015/udp
sudo fuser -k 27016/udp
```

#### Container Won't Start
```bash
# Check container logs
docker-compose logs unturned-server

# Check container status
docker-compose ps

# Restart with fresh configuration
docker-compose down
docker-compose up -d --force-recreate
```

### File Permission Commands Reference

```bash
# Set ownership to steam user (UID 1000)
sudo chown -R 1000:1000 ./server-data ./config

# Set proper permissions
sudo chmod -R 755 ./server-data ./config

# If using SELinux, set context
sudo setsebool -P container_use_cephfs on
sudo chcon -Rt svirt_sandbox_file_t ./server-data ./config

# For systems with strict permissions
sudo chmod 777 ./server-data ./config
```

### Debugging Steps

1. **Check Docker version**: `docker --version && docker-compose --version`
2. **Check available space**: `df -h`
3. **Check container logs**: `docker-compose logs -f unturned-server`
4. **Test SteamCMD manually**:
   ```bash
   docker run --rm -it cm2network/steamcmd:root bash
   /home/steam/steamcmd/steamcmd.sh +login anonymous +quit
   ```
5. **Verify network connectivity**: `docker run --rm alpine ping -c 3 steamcmd.com`

### Getting Help

If none of these solutions work:

1. Check the container logs: `docker-compose logs unturned-server`
2. Check system logs: `journalctl -u docker.service`
3. Verify your Docker installation is working: `docker run hello-world`
4. Join the Unturned community Discord or forums with your specific error message