#!/usr/bin/env bash
# ============================================================
#  Terminal AI - User Data & Application Restore
# ============================================================
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
  echo -e "${RED}[ERROR] You must provide the backup file.${NC}"
  echo -e "Usage: ./restore.sh /path/to/svnterm_data_XXXXX.tar.gz"
  exit 1
fi

ARCHIVE=$1

echo -e "${CYAN}→ Extracting snapshot files...${NC}"
# Extract the archive starting from the root directory to overwrite the fresh install
tar -xzf "$ARCHIVE" -C /

echo -e "${CYAN}→ Restoring PostgreSQL Database...${NC}"
# Drop the empty database made by the fresh install and replace it with your backup
sudo -u postgres psql -c "DROP DATABASE IF EXISTS terminalai;"
sudo -u postgres psql -c "CREATE DATABASE terminalai OWNER terminalai;"
sudo -u postgres psql terminalai < /tmp/terminalai_db.sql
rm /tmp/terminalai_db.sql

echo -e "${CYAN}→ Restarting services with restored configurations...${NC}"
cd /opt/terminal-ai
pm2 reload ecosystem.config.cjs --update-env || pm2 start ecosystem.config.cjs
systemctl reload nginx

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}[SUCCESS] Application data restored successfully!${NC}"
echo -e "${GREEN}================================================================${NC}"
