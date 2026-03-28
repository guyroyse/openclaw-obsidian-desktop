# OpenClaw Desktop

Run [OpenClaw](https://openclaw.dev) and [Obsidian](https://obsidian.md) together in a Docker container so your AI agent can interact with your Obsidian vault using the Obsidian CLI.

The Obsidian CLI requires the full Obsidian Desktop app to be running (it communicates via IPC), so this project packages everything inside a lightweight XFCE desktop accessible through your browser. Your agent gets shell access to the Obsidian CLI for searching, reading, writing, managing tasks, and more -- all without reading or writing markdown files directly.

## Prerequisites

- Docker and Docker Compose
- An Obsidian account with Sync (for pulling your vault into the container)

## Quick Start

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

4. Open the virtual desktop in your browser at `http://localhost:3000` (or whatever port you configured).

## Setting Up Obsidian

Once the desktop is running in your browser:

<!-- TODO: Fill in from onboarding experience -->

1. Obsidian should launch automatically. If not, open it from the applications menu.
2. Log into your Obsidian account.
3. Set up Obsidian Sync -- select your vault.
4. Enter your E2E encryption password.
5. Wait for the vault to sync down.
6. Go to Settings > General > enable Command Line Interface.
7. Follow the prompt to register the CLI.
8. Open a terminal and verify: `obsidian help`

<!-- TODO: Notes on what actually happened during onboarding -->
<!-- TODO: Any gotchas or things that weren't obvious -->

## Setting Up OpenClaw

<!-- TODO: Fill in from onboarding experience -->
<!-- TODO: openclaw gateway setup, Discord bot config, etc. -->

## Accessing the Desktop

The virtual desktop is served over HTTP on port 3000 (configurable via `PORT` in `.env`).

- **Local access:** `http://localhost:3000`
- **LAN access:** `http://<host-ip>:3000` -- the port is open to all interfaces by default.

You'll be prompted for the username and password you set in `.env`.

## What's in `config/`

The `config/` directory contains bind mounts that persist across container rebuilds. Only the things that matter are stored here -- everything else is ephemeral.

| Path | Container path | Purpose |
|------|---------------|---------|
| `config/obsidian/` | `/config/.config/obsidian` | Obsidian app config: account login, Sync settings, E2E encryption state, plugin configs, CLI registration. Preserving this means you don't have to redo the manual setup after a rebuild. |
| `config/openclaw/` | `/config/.openclaw` | OpenClaw config, memory, and logs. |

The vault data itself is **not** persisted in a bind mount. If the container is destroyed, Obsidian Sync pulls it back down.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PASSWORD` | *(required)* | Web desktop login password |
| `CUSTOM_USER` | `admin` | Web desktop login username |
| `HOSTNAME` | `openclaw` | Container hostname |
| `TITLE` | `OpenClaw Desktop` | Browser tab title |
| `TZ` | `UTC` | Container timezone |
| `PORT` | `3000` | Host port for web desktop |

API keys for your LLM provider and Discord bot token should also be set in `.env`. See `.env.sample` for examples.
