FROM lscr.io/linuxserver/webtop:ubuntu-xfce

ARG APT_LISTS=/var/lib/apt/lists/*

ARG OB_DEB_URL=https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian_1.12.7_amd64.deb
ARG OB_DEB_PATH=/tmp/obsidian.deb
ARG OB_DESKTOP_FILE=/usr/share/applications/obsidian.desktop
ARG OB_AUTOSTART=/etc/xdg/autostart/obsidian.desktop

# Update package index
RUN apt-get update

# Install Node.js
RUN apt-get install -y nodejs

# Install Obsidian Desktop
RUN curl -fsSL -o ${OB_DEB_PATH} ${OB_DEB_URL} && \
    apt-get install -y ${OB_DEB_PATH} && \
    rm -f ${OB_DEB_PATH}

# Clean up package index
RUN rm -rf ${APT_LISTS}
   
# Fix Obsidian launch in container (Electron needs --no-sandbox)
RUN sed -i \
    's|Exec=/opt/Obsidian/obsidian %U|Exec=/opt/Obsidian/obsidian --no-sandbox %U|' \
    ${OB_DESKTOP_FILE}

# Auto-start Obsidian with the desktop
RUN cp ${OB_DESKTOP_FILE} ${OB_AUTOSTART}

# Add ~/.local/bin to PATH (the Obsidian CLI binary is copied there at runtime)
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /etc/profile.d/obsidian-cli.sh

# Set default git identity (OpenClaw versions its workspace with git)
RUN git config --system user.name "OpenClaw" && \
    git config --system user.email "openclaw@localhost"

# Install OpenClaw
RUN npm install -g openclaw

# Clean up stale Obsidian lock files on container start
COPY s6/obsidian-init /custom-cont-init.d/obsidian-init

# Auto-start OpenClaw gateway as an s6 service
COPY s6/openclaw-init /custom-cont-init.d/openclaw-init
COPY s6/svc-openclaw /etc/s6-overlay/s6-rc.d/svc-openclaw

RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/svc-openclaw

