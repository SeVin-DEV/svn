#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}━━━ Alibaba Full Server Snapshot Utility ━━━${NC}"

# 1. Install Alibaba CLI if missing
if ! command -v aliyun &> /dev/null; then
    echo "→ Installing Alibaba Cloud CLI..."
    wget -q https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz
    tar xzf aliyun-cli-linux-latest-amd64.tgz
    sudo mv aliyun /usr/local/bin/
    rm aliyun-cli-linux-latest-amd64.tgz
fi

# Ensure jq is installed for parsing API responses
if ! command -v jq &> /dev/null; then
    sudo apt-get install -y jq -qq > /dev/null
fi

# 2. Check if the user has configured their API keys
if ! aliyun configure get &> /dev/null; then
    echo -e "${RED}[ERROR] Aliyun CLI is not configured with your credentials.${NC}"
    echo "Run 'aliyun configure' first to set your AccessKey ID and Secret."
    exit 1
fi

# 3. Ask the internal meta-data server for our exact identity
echo "→ Fetching instance metadata..."
REGION=$(curl -s http://100.100.100.200/latest/meta-data/region-id)
INSTANCE_ID=$(curl -s http://100.100.100.200/latest/meta-data/instance-id)

# 4. Ask the Alibaba API what our System Disk ID is
echo "→ Querying System Disk ID for instance ${INSTANCE_ID}..."
DISK_ID=$(aliyun ecs DescribeDisks --InstanceId "$INSTANCE_ID" --RegionId "$REGION" --DiskType system | jq -r '.Disks.Disk[0].DiskId')

if [ "$DISK_ID" == "null" ] || [ -z "$DISK_ID" ]; then
    echo -e "${RED}[ERROR] Could not locate the system disk via the API.${NC}"
    exit 1
fi

# 5. Trigger the Snapshot
SNAP_NAME="SVNTerm-Pristine-$(date +"%Y%m%d-%H%M%S")"
echo -e "→ Ordering Full Disk Snapshot: ${CYAN}${SNAP_NAME}${NC} (Disk: $DISK_ID)..."

aliyun ecs CreateSnapshot \
  --RegionId "$REGION" \
  --DiskId "$DISK_ID" \
  --SnapshotName "$SNAP_NAME" \
  --Description "Automated snapshot triggered from svnterm server terminal" > /dev/null

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}[SUCCESS] Full server snapshot initiated!${NC}"
echo "Alibaba is now cloning your hard drive in the background."
echo "You can safely keep working. The snapshot will appear in your Alibaba console shortly."
echo -e "${GREEN}================================================================${NC}"
