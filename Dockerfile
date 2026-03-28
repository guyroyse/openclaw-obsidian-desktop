FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Update package index
RUN apt-get update

# Install Node.js
RUN apt-get install -y nodejs && \
    npm install -g npm@latest

# Install OpenClaw
RUN npm install -g openclaw

# Install Obsidian Desktop
RUN curl -fsSL -o /tmp/obsidian.deb https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian_1.12.7_amd64.deb && \
    apt-get install -y /tmp/obsidian.deb && \
    rm -f /tmp/obsidian.deb

# Fix Obsidian launch in container (Electron needs --no-sandbox)
RUN sed -i 's|Exec=/opt/Obsidian/obsidian %U|Exec=/opt/Obsidian/obsidian --no-sandbox %U|' /usr/share/applications/obsidian.desktop

# Auto-start Obsidian with the desktop
RUN cp /usr/share/applications/obsidian.desktop /etc/xdg/autostart/obsidian.desktop

# Clean up package index
RUN rm -rf /var/lib/apt/lists/*

