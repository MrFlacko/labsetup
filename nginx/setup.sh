# NGINX Setup Commands
sudo apt install nginx certbot
sudo systemctl stop nginx
sudo ufw allow 80
# In cloudflare, add domain while proxy is turned on 
# Point the domain to your internal server IP (A Record)
sudo certbot certonly -d YOUR.DOMAIN.COMip a
sudo systemctl start nginx
# Option 1 
