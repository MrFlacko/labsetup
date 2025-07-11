# baseline
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# inbound ports (IPv4+IPv6 auto-covered)
sudo ufw allow 5055,7878,8080,8096,8989,9696/tcp comment "media apps"
sudo ufw allow 22/tcp       # SSH
sudo ufw allow 80,443/tcp   # HTTP/S
sudo ufw allow 2049/tcp     # NFS

# inbound nets
sudo ufw allow from 172.16.0.0/24
sudo ufw allow from 10.0.0.0/24
sudo ufw allow in proto igmp from 10.0.0.1 to 224.0.0.1

# outbound nets
sudo ufw allow out to 172.16.0.0/24
sudo ufw allow out to 10.0.0.0/24

sudo ufw enable
ufw status numbered
