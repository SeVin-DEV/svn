#!/usr/bin/env bash
# ============================================================
#  getgit.sh - GitHub SSH Key & Config Automator
# ============================================================
set -euo pipefail

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}━━━ Git & GitHub Setup ━━━${NC}"

# 1. Gather Git Info
read -rp "Enter your Git User Name (e.g., Kayden): " GIT_NAME
read -rp "Enter your Git Email (e.g., you@example.com): " GIT_EMAIL

echo -e "\n${CYAN}→ Configuring global Git variables...${NC}"
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

# 2. SSH Key Generation
SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ -f "$KEY_FILE" ]]; then
    echo -e "${YELLOW}An Ed25519 key already exists. Skipping generation.${NC}"
else
    echo -e "${CYAN}→ Generating new Ed25519 SSH key...${NC}"
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_FILE" -N "" -q
fi

# 3. Start Agent & Add Key
eval "$(ssh-agent -s)" > /dev/null
ssh-add "$KEY_FILE" 2>/dev/null

# 4. Add GitHub to Known Hosts (Prevents the "authenticity of host" prompt)
echo -e "${CYAN}→ Adding GitHub to known_hosts...${NC}"
ssh-keyscan -t ed25519 github.com >> "$SSH_DIR/known_hosts" 2>/dev/null
# Remove duplicates just in case
sort -u "$SSH_DIR/known_hosts" -o "$SSH_DIR/known_hosts"
chmod 644 "$SSH_DIR/known_hosts"

# 5. Output Public Key
echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}SUCCESS! Your Git environment is configured.${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "To give this server access to your repo, go to:"
echo -e "GitHub -> Your Repository -> Settings -> ${YELLOW}Deploy keys${NC} -> Add deploy key"
echo ""
echo -e "Name it something like: ${CYAN}Alibaba svnterm Backend${NC}"
echo -e "Copy the following key exactly as it appears below:\n"

cat "${KEY_FILE}.pub"

echo -e "\n${GREEN}================================================================${NC}"
echo -e "Once you add the key to GitHub, test the connection by running:"
echo -e "  ${CYAN}ssh -T git@github.com${NC}"
echo ""
