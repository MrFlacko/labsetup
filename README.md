# JellyFin Setup
## How the workflow fits together
1. **Jellyseerr** authenticates to Jellyfin via an API key you create in the Jellyfin admin UI.  
2. Users place requests in Jellyseerr → it forwards the approved items to **Sonarr** (TV) or **Radarr** (movies) using their API keys.  
3. Sonarr/Radarr ask **Prowlarr** for an NZB → Prowlarr queries all configured Usenet indexers.  
4. **SABnzbd / NZBGet** downloads the NZB, extracts it into `/downloads/completed`.  
5. Sonarr/Radarr move and rename the file into `/tv` or `/movies`.  
6. Jellyfin’s real-time monitor (or a scheduled library refresh) spots the new file and adds it to your library—ready to stream.

## Container lineup
| Service | Purpose | Key mounts / ports |
|---------|---------|--------------------|
| **jellyfin** (`linuxserver/jellyfin`) | Streams your media library via web UI, DLNA, apps. | `/config` → DB + plugins<br>`/movies`, `/tv` → read-only media folders<br>**8096/tcp** |
| **sabnzbd** or **nzbget** | Pulls files from Usenet, extracts, moves to the **downloads** dir that Sonarr/Radarr watch. | `/downloads` → temp & completed stash<br>**8080/tcp** (SAB) or **6789/tcp** (NZBGet) |
| **sonarr** | Monitors TV shows, grabs NZBs via Prowlarr, tells the downloader to fetch, post-processes into `/tv`. | `/downloads` (watch) and `/tv` (final)<br>**8989/tcp** |
| **radarr** | Same as Sonarr but for movies, outputting into `/movies`. | `/downloads`, `/movies`<br>**7878/tcp** |
| **prowlarr** | Central indexer hub; feeds Sonarr/Radarr a single API endpoint and manages indexer logins/rate-limits. | `/config` only<br>**9696/tcp** |
| **jellyseerr** | Request portal (Overseerr fork) that speaks Jellyfin’s API; friends search your library, click “request,” and it pushes to Sonarr/Radarr. | `/config` only<br>**5055/tcp** |
