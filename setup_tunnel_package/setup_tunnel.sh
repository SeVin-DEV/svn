#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}→ Checking for cloudflared...${NC}"
if ! command -v cloudflared &> /dev/null; then
    echo -e "${CYAN}→ Downloading and installing cloudflared...${NC}"
    curl -L -o /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i /tmp/cloudflared.deb
    rm /tmp/cloudflared.deb
else
    echo -e "${GREEN}✓ cloudflared is already installed.${NC}"
fi

echo -e "${CYAN}→ Creating global shortcut 'start-tunnel'...${NC}"

# Drop the shortcut script directly into the global path
sudo tee /usr/local/bin/start-tunnel > /dev/null << 'INNER_EOF'
#!/usr/bin/env bash
echo -e "\033[0;36mStarting Cloudflare tunnel to localhost:80...\033[0m"
cloudflared tunnel --url http://localhost:80
INNER_EOF

# Make the shortcut executable
sudo chmod +x /usr/local/bin/start-tunnel

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}[SUCCESS] Setup complete!${NC}"
echo -e "You can now type ${CYAN}start-tunnel${NC} from ANY directory to open the tunnel."
echo -e "${GREEN}================================================================${NC}"
