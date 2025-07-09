# NGINX Setup Commands Certbot grabbing certificate as well
sudo apt install nginx certbot
sudo systemctl stop nginx
sudo ufw allow 80
# In cloudflare, add domain while proxy is turned on 
# Point the domain to your internal server IP (A Record)
sudo certbot certonly -d YOUR.DOMAIN.COM
sudo systemctl start nginx
# Option 1 
sudo rm /etc/nginx/sites-available/default
