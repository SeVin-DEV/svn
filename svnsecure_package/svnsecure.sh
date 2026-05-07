#!/usr/bin/env bash

# ==============================================================================
# newsvr.sh - The Unofficial Anti-Red Text Wall Server Primer
# Purpose: Bulletproof a fresh ECS instance against compilation & dependency errors.
# ==============================================================================

# Exit immediately if a command fails
set -e 

# Define colors for readable output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[*] Initializing the Anti-Red Wall sequence...${NC}"

# 1. System Update & Upgrade
echo -e "${GREEN}[+] Updating system package lists and upgrading base packages...${NC}"
sudo apt update -q -y
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -q -y

# 2. Build & Crypto Shields (The Dependency Armor)
echo -e "${GREEN}[+] Installing build essentials and core development headers...${NC}"
sudo DEBIAN_FRONTEND=noninteractive apt install -q -y \
    build-essential \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev

# 3. Terminal & Scripting Survival Kit
echo -e "${GREEN}[+] Installing terminal utilities and parsing tools...${NC}"
sudo DEBIAN_FRONTEND=noninteractive apt install -q -y \
    tmux \
    jq \
    htop \
    net-tools \
    curl \
    wget \
    unzip \
    tar \
    tree

# 4. The Network Bouncer
echo -e "${GREEN}[+] Installing and configuring UFW (Firewall)...${NC}"
sudo DEBIAN_FRONTEND=noninteractive apt install -q -y ufw

echo -e "${BLUE}[*] Permitting OpenSSH so you don't lock yourself out...${NC}"
sudo ufw allow OpenSSH

echo -e "${BLUE}[*] Enabling UFW silently...${NC}"
sudo ufw --force enable

echo -e "${GREEN}[========== INITIALIZATION COMPLETE ==========]${NC}"
echo -e "${BLUE}[*] The server is now armored. You are clear to start building svnterm.${NC}"
