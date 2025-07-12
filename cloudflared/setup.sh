sudo apt update
sudo apt install -y curl gnupg apt-transport-https

# 1. Add Cloudflare’s GPG key
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
  | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# 2. Add the cloudflared repo
echo \
  "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] \
   https://pkg.cloudflare.com/cloudflared focal main" \
  | sudo tee /etc/apt/sources.list.d/cloudflared.list

# 3. Update and install
sudo apt update
sudo apt install -y cloudflared

cd ~/.cloudflared
cloudflared tunnel login
# Opens a browser, log in and select the domain
cloudflared tunnel create homelab-tunnel # Creates your tunnel with cloudflare to your server
cloudflared tunnel route dns homelab-tunnel watch.flacko.net #Creates a cname on cloudflare to allow public searching when authenticated
cloudflared tunnel route dns homelab-tunnel request.flacko.net

## Within the cloudflare website
# Open Zero trusts and set up a new workspace
# Add an IDP for github 

## In Github for users
# access https://github.com/settings/applications/new
# Give it a name and descript
# https://<your-team-name>.cloudflareaccess.com  -- Copy in Homepage URL 
# https://<your-team-name>.cloudflareaccess.com/cdn-cgi/access/callback -- Authorization callback URL
# Enable device flow not really needed, it will show a code where you can enter in another browser. Mean for IoT devices that don't have browsers.
# Add the app

## In Zero Trust https://one.dash.cloudflare.com/
# go Settings > Authentication > Login methods
# Click Add New > Github
# Copy the AppID and generate a new Client secret and add it
# Test next to your github login method through Settings > Authentication > Login methods > Test

## Add your application
# Cloudflare Zero Trusts > Access > Applications > Add Application > Self-Hosted [Select] 
# Set up Cloudflare warp with no rules, there's a URL to manage cloudflare warp and enable it.

## Add a policy
# Cloudflare Zero > Policies > Add a policy
# Give it a name and click done

## Setting up the service
sudo mkdir -p /etc/cloudflared
sudo tee /etc/cloudflared/config.yml > /dev/null <<EOF
tunnel: UUIDFORAPPLICATION
credentials-file: /etc/cloudflared/UUIDFORAPPLICATION.json

ingress:
  - hostname: watch.flacko.net
    service: http://localhost:8096

  - service: http_status:404
EOF
sudo cp ~/.cloudflared/UUIDFORAPPLICATION.json \
        /etc/cloudflared/
sudo chown root:root /etc/cloudflared/*
sudo chmod 600 /etc/cloudflared/*

sudo cloudflared service install
sudo systemctl enable --now cloudflared

## Troubleshooting 
# Had to head to ZeroTrust > Access > Applications
# Edit the Application I Created, add Github as an Auth Method leaving Org empty
# Then ZeroTrust > Access > Policies and link up the policy with the app
# Hadd to also edit and add an Include, setting to Login Method > Github, not Github Organization


