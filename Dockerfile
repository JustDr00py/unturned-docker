FROM cm2network/steamcmd:root

# Set environment variables
ENV USER steam
ENV HOME /home/steam
ENV SERVER_DIR /home/steam/unturned-server

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    lib32gcc-s1 \
    lib32stdc++6 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p $SERVER_DIR \
    && mkdir -p /home/steam/scripts \
    && mkdir -p /home/steam/config

# Create a startup script
COPY scripts/start-server.sh /home/steam/scripts/
RUN chmod +x /home/steam/scripts/start-server.sh

# Create environment setup script
COPY scripts/setup-env.sh /home/steam/scripts/
RUN chmod +x /home/steam/scripts/setup-env.sh

# Set ownership
RUN chown -R steam:steam /home/steam

# Switch to steam user
USER steam
WORKDIR $HOME

# Install Unturned dedicated server
RUN /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir $SERVER_DIR \
    +login anonymous \
    +app_update 1110390 validate \
    +quit

# Expose ports
EXPOSE 27015/udp 27016/udp

# Set the entrypoint
ENTRYPOINT ["/home/steam/scripts/start-server.sh"]