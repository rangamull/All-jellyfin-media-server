Here is the complete, finalized order of operations. I have structured this as a raw Markdown file that you can copy, save as `README.md` or `INSTALL.md`, and keep right alongside your project files for future reference.

It strictly adheres to your custom path: `revamp/docker-compose.yaml`.

````markdown
# Media Server Deployment Guide

This document outlines the exact order of execution required to bootstrap directories, seed core application configurations, inject API keys, and launch the media server stack.

---

## Architecture Overview

By following this exact sequence, the entire stack will be deployed with a unified storage path (`/data`). This design ensures that **atomic moves and hardlinks** function natively between qBittorrent, Sonarr, and Radarr, completely eliminating storage waste and slow file-copy operations.

---

## Step-by-Step Deployment

### Step 1: Environment Initialization

**Responsibility:** Generates permanent 32-character hexadecimal API keys for Sonarr, Radarr, and Prowlarr, and saves them to a centralized `.env` file. Docker Compose reads this file automatically to lock down container security on boot.

1. Create and execute the environment script:
   ```bash
   chmod +x setup_env.sh
   ./setup_env.sh
   ```
````

2. **Crucial:** Open the newly generated `.env` file and update the `COMMON_PATH` variable to point to your actual storage array (e.g., `/mnt/storage/media`).

---

### Step 2: Bootstrap Host Directories and Pre-seed Configs

**Responsibility:** Creates all mandatory directory structures on the host system _before_ the containers start. This prevents Docker from creating folders with restrictive root permissions. It also pre-seeds the network/configuration parameters for qBittorrent and Bazarr so they are instantly linked upon booting.

1. Make all bootstrap scripts executable:

```bash
chmod +x setup_qbittorrent.sh setup_jellyfin.sh setup_bazarr.sh setup_homarr.sh

```

2. Execute the bootstrap scripts in any order:

```bash
./setup_qbittorrent.sh
./setup_jellyfin.sh
./setup_bazarr.sh
./setup_homarr.sh

```

---

### Step 3: Launch the Docker Container Stack

**Responsibility:** Spins up your network interface (Gluetun/Surfshark), download clients, media indices, management arrs, and dashboards via Docker Compose using your specific file path.

1. Deploy the stack in detached mode:

```bash
docker compose -f revamp/docker-compose.yaml up -d

```

2. Verify all containers are running successfully:

```bash
docker compose -f revamp/docker-compose.yaml ps

```

3. Allow **1 to 2 minutes** for all application internal web servers to fully initialize before proceeding to Step 4.

---

### Step 4: Automate App-to-App API Integrations

**Responsibility:** Uses curl to hit the internal REST APIs of Sonarr and Radarr. This automatically attaches qBittorrent as their primary download client, applies proper download categories, and establishes immediate inter-container communications.

1. Make the API integration scripts executable:

```bash
chmod +x setup_sonarr.sh setup_radarr.sh

```

2. Execute the API configuration scripts:

```bash
./setup_sonarr.sh
./setup_radarr.sh

```

---

### Step 5: Manual Web UI Finalization

**Responsibility:** Completes setups for software that relies on internal database structures or interactive user wizards which cannot be safely scripted via bash.

| Application    | Address                 | Mandatory Action                                                                                                                                            |
| -------------- | ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Jellyfin**   | `http://localhost:8096` | Complete the wizard, add libraries pointing to `/data/sonarr/tv` and `/data/radarr/movies`. Go to _Dashboard -> API Keys_ to generate a key for Jellyseerr. |
| **Homarr**     | `http://localhost:7575` | Create your admin account. Add widgets for your services. Use internal container domains (e.g., `http://sonarr:8989`) for integrations.                     |
| **Prowlarr**   | `http://localhost:9696` | Go to _Settings -> Apps_, add Sonarr/Radarr using the permanent API keys found in your `.env` file to sync indexers.                                        |
| **Jellyseerr** | `http://localhost:5055` | Log in, point it to Radarr (`http://radarr:7878`), Sonarr (`http://sonarr:8989`), and input the Jellyfin API key generated above.                           |

---

## Summary of Stack Operations

```
[User Request] -> Jellyseerr -> Sonarr/Radarr -> Prowlarr (Finds Torrents)
                                     │
                                     ▼
                                qBittorrent (Downloads to /data/qbittorrent/downloads)
                                     │
                                     ▼ (Instant Hardlink triggered via /data)
                                Sonarr/Radarr (Hardlinks to /data/sonarr or /data/radarr)
                                     │
                                     ├──> Jellyfin (Streams to Client - Direct Play)
                                     └──> Bazarr (Scans and drops .srt subtitles)

```
