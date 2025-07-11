# reset & policy
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# inbound TCP ports – IPv4-only because src is 0.0.0.0/0
sudo ufw allow from 0.0.0.0/0 to any port 5055,7878,8080,8096,8989,9696 proto tcp comment "Used with Jellyfin"
sudo ufw allow from 0.0.0.0/0 to any port 22   proto tcp comment "Allow SSH"
sudo ufw allow from 0.0.0.0/0 to any port 80,443 proto tcp comment "HTTP and HTTPS"
sudo ufw allow from 0.0.0.0/0 to any port 2049 proto tcp comment "NFS"
sudo ufw allow from 0.0.0.0/0 to any port 19999 proto tcp comment "NetData"

# inbound trusted subnets. These are temporary
sudo ufw allow from 172.16.0.0/24 comment "Allow connection from 172.16.0.0/24 Network in"
sudo ufw allow from 10.0.0.0/24 comment "Allow connection from 10.0.0.0/24 Network in"
sudo ufw allow in proto igmp from 10.0.0.1 to 224.0.0.1 comment "Allowing IGMP connections from Edge router"

# outbound to those subnets. These are temporary
sudo ufw allow out to 172.16.0.0/24 comment "Allow connection from 172.16.0.0/24 Network out"
sudo ufw allow out to 10.0.0.0/24 comment "Allow connection from 10.0.0.0/24 Network out"

sudo sudo ufw enable
sudo ufw status numbered
