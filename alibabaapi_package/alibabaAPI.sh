#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━ Alibaba Cloud CLI (aliyun) Setup ━━━${NC}"

if ! command -v aliyun &> /dev/null; then
    echo -e "${CYAN}→ Downloading the latest Alibaba Cloud CLI...${NC}"
    wget -q https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz

    echo -e "${CYAN}→ Extracting and installing...${NC}"
    tar xzf aliyun-cli-linux-latest-amd64.tgz

    # Move it to the global binaries folder
    sudo mv aliyun /usr/local/bin/

    # Clean up the downloaded archive
    rm aliyun-cli-linux-latest-amd64.tgz
    echo -e "${GREEN}[+] aliyun CLI installed successfully!${NC}"
else
    echo -e "${GREEN}[+] aliyun CLI is already installed.${NC}"
fi

echo -e "------------------------------------------------------------"
echo -e "${CYAN}→ Launching Interactive Alibaba Configuration...${NC}"
echo -e "You will need your AccessKey ID, AccessKey Secret, and Region Id."
echo -e "(Example Region Id: us-east-1, cn-hangzhou, ap-southeast-1)"
echo -e "------------------------------------------------------------"

# Launch the official configuration prompt
aliyun configure

echo -e "------------------------------------------------------------"
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}[SUCCESS] Alibaba CLI installed and configured!${NC}"
echo -e "You can now command your cloud infrastructure directly."
echo -e "Example: ${CYAN}aliyun ecs DescribeInstances${NC}"
echo -e "${GREEN}================================================================${NC}"
