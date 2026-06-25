# Media Server Deployment Guide

This document outlines the exact order of execution required to initialize your environment, bootstrap all system directory structures, and deploy your fully automated media stack.

---

## Architecture Overview

By following this exact sequence, the entire stack will deploy with a unified storage path (`/data`) mapped to your host. This ensures that **atomic moves and hardlinks** function natively between qBittorrent, Sonarr, and Radarr, completely eliminating storage waste and disk overhead. All applications are secured behind custom User/Group IDs to prevent permission errors.

---

## Step-by-Step Deployment

### Step 1: Environment Initialization

**Responsibility:** Automatically captures your host system's non-root `LOCAL_UID` and `LOCAL_GID`, generates permanent 32-character hexadecimal API keys for your services, and saves them to a centralized `.env` file. Docker Compose reads this file automatically on boot to secure container permissions and API integrations.

1. Make the environment script executable and run it:

   ```bash
   chmod +x setup_env.sh
   ./setup_env.sh
   ```

2. **Crucial:** Open the newly generated `.env` file and update your custom paths and credentials:

- Set `COMMON_PATH` to your storage array (e.g., `/mnt/storage/media`).
- Add your Surfshark Wireguard credentials (`PRIVATE_KEY` and `WIREGUARD_ADDR`).

---

### Step 2: Bootstrap Host Directories

**Responsibility:** Creates all mandatory configuration and cache directory structures on the host filesystem _before_ the containers start. This ensures files are pre-owned by your user account rather than letting Docker generate them as `root`. It also pre-seeds necessary config templates.

1. Make the application bootstrap script executable and run it:

```bash
chmod +x setup_apps.sh
./setup_apps.sh

```

---

### Step 3: Launch the Docker Container Stack

**Responsibility:** Pulls the required images and spins up your network interface (Gluetun/Surfshark), download clients, media indexing managers, transcoding nodes, automated updates, and dashboards via Docker Compose.

1. Deploy the stack in detached mode:

```bash
docker-compose -f revamp/docker-compose.yaml  up -d

```

2. Verify all containers are running successfully:

```bash
docker-compose -f revamp/docker-compose.yaml  ps

```

3. Allow **1 to 2 minutes** for all internal application databases and web servers to fully initialize before accessing their dashboards.

---

### Step 4: Web UI Finalization & Integrations

**Responsibility:** Completes setups for software that relies on internal application wizards or custom UI-driven configurations.

| Application     | Address                 | Mandatory Action / Connection Details                                                                                                                                                 |
| --------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Homarr**      | `http://localhost:7575` | Create your master admin account. Go to _Settings -> Integrations_ to add Docker (internal socket) and Dashdot (`http://dashdot:3001`). Turn on CPU/RAM columns in the Docker widget. |
| **Dashdot**     | `http://localhost:3001` | Runs automatically to feed system metrics (including GPU thermals/load) directly into your Homarr dashboard widgets.                                                                  |
| **qBittorrent** | `http://localhost:8081` | Access the Web UI                                                                                                                                                                     |
| **Prowlarr**    | `http://localhost:9696` | Go to _Settings -> Apps_, add Sonarr and Radarr using the permanent API keys generated in your `.env` file to instantly sync indexers.                                                |
| **Sonarr**      | `http://localhost:8989` | Handled by script, but verify under _Settings -> Download Clients_ that `qbittorrent` is listed with a green checkmark. Add your initial TV Series.                                   |
| **Radarr**      | `http://localhost:7878` | Handled by script, but verify under _Settings -> Download Clients_ that `qbittorrent` is listed with a green checkmark. Add your initial Movies.                                      |
| **Jellyseerr**  | `http://localhost:5055` | Follow the login prompt. Link it internally to Radarr (`http://radarr:7878`), Sonarr (`http://sonarr:8989`), and input your Jellyfin API key.                                         |
| **Jellyfin**    | `http://localhost:8096` | Complete the wizard. Add your libraries pointing to `/data/sonarr` and `/data/radarr`. Navigate to _Dashboard -> API Keys_ to generate an access token for Jellyseerr.                |
| **Tdarr**       | `http://localhost:8265` | Go to the _Libraries_ tab. Add your `/data` media path and assign transcoding plugins to automate file sizing and GPU acceleration.                                                   |

---

## Summary of Stack Operations

```
   [User Request via Web] -> Jellyseerr -> Sonarr / Radarr -> Prowlarr
                                                │
                                                ▼ (Routed through Surfshark VPN)
                                           qBittorrent (Downloads to /data/...)
                                                │
                                                ▼ (Instant Hardlink triggered via /data)
                                           Sonarr / Radarr (Sorts into media folders)
                                                │
         ┌──────────────────────────────────────┴──────────────────────────────────────┐
         ▼                                      ▼                                      ▼
Jellyfin (Streams Video)             Tdarr (Transcodes / Shrinks)            Recyclarr (Syncs TRaSH Profiles)

```

## Maintenance Commands

- **View live service logs:**

```bash
docker-compose -f revamp/docker-compose.yaml logs -f [service_name]

```

- **Gracefully stop the entire stack:**

```bash
docker-compose -f revamp/docker-compose.yaml down

```

- **Fix legacy permissions if you accidentally run commands as root:**

```bash
sudo chown -R $(id -u):$(id -g) /path/to/your/common_path

```

_(Note: Watchtower runs automatically in the background at 4:00 AM daily to check for application updates, cleanly recycling containers and clearing out stale Docker layers.)_

```

```

# fix homarr:

```bash
docker stop homarr2
docker rm homarr2
docker-compose -f Documents/All-jellyfin-media-server/revamp/docker-compose.yaml up -d homarr
```

# fix "root" permission issue

```bash
id
# check UID/GID values generated (do the substitution on below)
sudo chown -R uid:gid ${COMMON_PATH}
# then update the docker-compose PUID/PGID values with the same (from env is probs easiest)
```
