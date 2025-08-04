# Unturned Dedicated Server Docker Setup

This Docker Compose setup allows you to easily run an Unturned dedicated server with full configuration through environment variables.

## Quick Start

1. **Clone or download all files** to a directory on your server
2. **Edit the `.env` file** with your desired server configuration
3. **Run the server**:
   ```bash
   docker-compose up -d
   ```

## File Structure

```
unturned-server/
├── docker-compose.yml     # Main Docker Compose configuration
├── Dockerfile            # Custom Docker image (optional)
├── .env                  # Environment variables configuration
├── config/
│   ├── Config.json       # Server configuration template
│   └── Commands.dat      # Custom server commands
├── scripts/
│   ├── start-server.sh   # Server startup script
│   └── setup-env.sh      # Environment setup script
├── server-data/          # Server data directory (created automatically)
└── README.md            # This file
```

## Configuration

### Environment Variables (.env file)

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | MyUnturnedServer | Server name displayed in browser |
| `SERVER_PASSWORD` | (empty) | Server password (leave empty for no password) |
| `MAX_PLAYERS` | 24 | Maximum number of players |
| `SERVER_PORT` | 27015 | Server port |
| `QUERY_PORT` | 27016 | Query port |
| `MAP` | PEI | Map name (PEI, Washington, Russia, etc.) |
| `DIFFICULTY` | Normal | Difficulty (Easy, Normal, Hard) |
| `MODE` | Survival | Game mode |
| `PERSPECTIVE` | Both | Camera perspective (First, Third, Both, Vehicle) |
| `PVP` | true | Enable PvP |
| `BATTLEYE` | true | Enable BattlEye anti-cheat |
| `CHEATS` | false | Enable cheats |
| `OWNER_ID` | (empty) | Steam64 ID of server owner |
| `ADMIN_IDS` | (empty) | Comma-separated Steam64 IDs of admins |
| `WORKSHOP_FILE_IDS` | (empty) | Comma-separated Workshop item IDs |

### Workshop Items

To add Workshop mods/maps, add their Steam Workshop file IDs to the `WORKSHOP_FILE_IDS` variable:
```env
WORKSHOP_FILE_IDS=1234567890,0987654321,1111111111
```

### Admin Setup

1. Get your Steam64 ID from [steamid.io](https://steamid.io)
2. Add it to `OWNER_ID` for full admin privileges
3. Add additional admin Steam64 IDs to `ADMIN_IDS` (comma-separated)

## Commands

### Start the server
```bash
docker-compose up -d
```

### Stop the server
```bash
docker-compose down
```

### View server logs
```bash
docker-compose logs -f unturned-server
```

### Restart the server
```bash
docker-compose restart unturned-server
```

### Update server
The server will automatically check for updates on startup. To force an update:
```bash
docker-compose down
docker-compose up -d
```

## Server Management

### Accessing Server Console
```bash
docker exec -it unturned-dedicated-server bash
```

### Server Files Location
- **Server data**: `./server-data/`
- **Configuration**: `./server-data/Servers/[SERVER_NAME]/`
- **Logs**: `./server-data/Logs/`
- **Workshop content**: `./server-data/Workshop/`

### Backup Your Server
```bash
# Create backup
tar -czf unturned-backup-$(date +%Y%m%d-%H%M%S).tar.gz server-data/

# Restore backup
tar -xzf unturned-backup-YYYYMMDD-HHMMSS.tar.gz
```

## Port Configuration

Make sure these ports are open on your firewall:
- **27015/UDP** - Game port
- **27016/UDP** - Query port

For iptables:
```bash
sudo iptables -A INPUT -p udp --dport 27015 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 27016 -j ACCEPT
```

## Troubleshooting

### Server won't start
1. Check the logs: `docker-compose logs unturned-server`
2. Verify your `.env` configuration
3. Ensure ports aren't already in use
4. Check Steam64 IDs are correct format

### Can't connect to server
1. Verify ports are open in firewall
2. Check `SERVER_PORT` matches what you're connecting to
3. Ensure server is running: `docker-compose ps`

### Workshop items not loading
1. Verify Workshop file IDs are correct
2. Check server logs for download errors
3. Ensure Workshop items are compatible with your server version

## Advanced Configuration

### Custom Server Config
Edit `config/Config.json` to customize advanced server settings. Changes will be automatically applied on server restart.

### Custom Commands
Add custom server commands to `config/Commands.dat`.

### Multiple Servers
To run multiple servers, copy this setup to different directories and change the `SERVER_NAME` and ports in each `.env` file.

## Security Notes

- Never share your `.env` file publicly as it may contain sensitive information
- Use strong passwords for admin accounts
- Regularly update your server for security patches
- Consider using a VPN for admin access

## Support

For Unturned server issues, check:
- [Unturned Official Documentation](https://github.com/SmartlyDressedGames/Unturned-3.x-Community)
- [Steam Community Guides](https://steamcommunity.com/app/304930/guides/)
- Server logs in `./server-data/Logs/`