# JellyFin
sudo mkdir -p /mnt/big/{Movies,Shows,Music,Books}
sudo chown -R 1000:1000 /mnt/big/{Movies,Shows,Music,Books}

# JellySeerr
sudo mkdir -p /srv/media/config/jellyseerr
sudo chown 1000:1000 /srv/media/config/jellyseerr

# SABnzbd
sudo mkdir -p /mnt/big/SabDownloads/{Movies,Shows}
sudo chown 1000:1000 /mnt/big/SabDownloads/{Movies,Shows}

# SABnzbd will default to IPV6 Address ::
# Sonarr and Radarr will need to connect to it with 172.16.0.10 or the Server IP
# Set up JellyFin > JellySAeer > Sonarr > Radarr > Sabnzbd > Prowlarr in that order
