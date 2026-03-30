# OpenClaw Desktop

Run [OpenClaw](https://openclaw.ai) and [Obsidian](https://obsidian.md) together in a Docker container so your AI agent can interact with your Obsidian vault using the Obsidian CLI.

The Obsidian CLI requires the full Obsidian Desktop app to be running (it communicates via IPC), so this project packages everything inside a lightweight XFCE desktop accessible through your browser. Your agent gets shell access to the Obsidian CLI for searching, reading, writing, managing tasks, and more -- all without reading or writing markdown files directly.

## Prerequisites

- Docker and Docker Compose
- An Obsidian account with Sync (for pulling your vault into the container)

> **Security note:** The OpenClaw gateway is configured to bind to all network interfaces (LAN mode) so you can access the web UI from other machines on your network. This means anyone on your local network can reach the gateway. Token authentication is enabled by default, but this setup is designed for use on a trusted home network -- not a public or shared network.

## Getting Started

You'll be doing three main things to get this up and running:

1. Buiding the image and getting the container running.
2. Configuring Obsidian and Obsidian Sync within the container.
3. Configuring OpenClaw within the container.

### Running the Container

1. Clone the repo:

   ```bash
   git clone <repo-url>
   cd openclaw-desktop
   ```

2. Create your `.env` file:

   ```bash
   cp .env.sample .env
   ```

   Edit `.env` and set at least `PASSWORD`. See `.env.sample` for all available options.

3. Build and start the container:

   ```bash
   docker compose up -d
   ```

4. Open the virtual desktop in your browser:

   You can use either localhost or access it over your network:
   - **Local access:** `http://localhost:3000`
   - **LAN access:** `http://your-mahcine.local:3000`

   You'll be prompted for the username and password you set in `.env`.

Once the desktop is running in your browser you'll see that Obsidian is already launched.

### Setting Up Obsidian

First, we'll set up Obsidian Sync:

1. Log into your Obsidian account.

2. Select which vault from your Obsidian Sync you want to use and **Connect** it.

3. When prompted for the vault location, set it to `/config/Obsidian` and **Create** it. This path is bind-mounted to `vaults/` on the host, so your vault will persist across container rebuilds.

4. Enter your E2E encryption password if needed and **Unlock vault**.

5. **Start syncing** and wait for it to finish.

Next, let's set up the command line interface so OpenClaw can use the CLI to talk to Obsidian:

1. Go to ⚙️ Settings > General and toggle the **Command line interface** to on.

2. Follow the prompt to register the CLI which will add the CLI to your system path.

3. Open a terminal and verify it works.

   ```bash
   obsidian help
   ```

4. If it worked, you will see the help for Obsidian CLI.

Next, we need to enable community plugins and enable them to be synced. If you're not using any plugins and never plan to, you can skip these steps:

1. Go to ⚙️ Settings > Community plugins and **Turn on community plugins**.

2. Also turn on **Automatically check for plugin updates**.

3. Go to Sync and toggle **Active community plugin list** and **Installed community plugins** to on. This will allow OpenClaw to manage plugins on your behalf and have them sync to your other devices. If you tell it to, of course.

4. Close Obsidian and relaunch it. Any plugins you have should now be loaded.

All of these settings are stored in `config/obsidian/` on the host, and your vault data is stored in `vaults/` on the host, so you only need to do this once. If you need to rebuild the container (e.g. to upgrade Obsidian or Node.js), just tear it down and bring it back up -- your login, Sync config, plugin settings, and vault data will all be there.

### Setting Up OpenClaw

OpenClaw is already installed and its gateway is running. You can access the web UI, but there's no AI provider configured, no skills installed, and no communication channels set up yet. We need to run through the onboarding process to set all of that up.

1. Launch a command-line Terminal if one isn't already open.

2. Start OpenClaw's onboarding process and follow the instructions:

   ```bash
   openclaw onboard --skip-daemon --skip-health
   ```

   The `--skip-daemon` flag skips the systemd service install, which doesn't work in a container. The gateway is already running via s6-overlay instead. The `--skip-health` flag skips the health check, which expects systemd and reports a false failure.

3. When prompted about **Config handling**, choose **Use existing values**. The gateway has already been configured for LAN access by the container's startup scripts.

4. Look at your openclaw.json file. This will be on your host system in the `config/openclaw` folder or in the virtual desktop in `~/.openclaw`. Regardless of how you access it, look for your gateway auth token. It should be near the bottom of the file. Copy it.

5. Navigate in your browser to http://127.0.0.1:18789/. In the **Gateway Token** field, paste your gateway auth token and click **Connect**.

6. You should now be able to chat with OpenClaw in the web interface. Say something to it like "Hello?" or my favorite, "Happy birthday!". It'll response and guide you through the rest of the setup process.

7. Try accessing OpenClaw from a web browser outside of the container as well. use the same token as before when prompted. I recommend putting the token in a password manager.

8. You will be told that pairing is required. Go back into the browser in the virtual desktop and ask OpenClaw to approve the request. It might ask some clarifying questions.

9. You'll need to do this for each new browser you set up but you can ask OpenClaw to confirm the pairing request from any browser you have successfully pair and from any other private channel you use to talk to it.

## Reference

### Persistent Data

The following directories are bind-mounted to persist across container rebuilds. Only the things that matter are stored here -- everything else is ephemeral.

| Host path          | Container path             | Purpose                         |
| ------------------ | -------------------------- | ------------------------------- |
| `config/obsidian/` | `/config/.config/obsidian` | Obsidian settings               |
| `config/openclaw/` | `/config/.openclaw`        | OpenClaw settings and workspace |
| `vaults/`          | `/config/Obsidian`         | Obsidian vault data             |

### Environment Variables

| Variable        | Default            | Description                   |
| --------------- | ------------------ | ----------------------------- |
| `PASSWORD`      | _(required)_       | Web desktop login password    |
| `CUSTOM_USER`   | `admin`            | Web desktop login username    |
| `HOSTNAME`      | `openclaw`         | Container hostname            |
| `TITLE`         | `OpenClaw Desktop` | Browser tab title             |
| `TZ`            | `UTC`              | Container timezone            |
| `PORT`          | `3000`             | Host port for web desktop     |
| `OPENCLAW_PORT` | `18789`            | Host port for OpenClaw web UI |

API keys for your LLM provider and Discord bot token should also be set in `.env`. See `.env.sample` for examples.
