#!/usr/bin/env bash
# ============================================================
#  Terminal AI - User Data & Application Backup (Full /opt/)
# ============================================================
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/root/backups"
ARCHIVE_NAME="svnterm_data_$BACKUP_DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

echo -e "${CYAN}→ Dumping PostgreSQL Database...${NC}"
sudo -u postgres pg_dump terminalai > /tmp/terminalai_db.sql

echo -e "${CYAN}→ Archiving user files, /opt/, and configurations...${NC}"
# Tar up everything, now including the entirety of /opt
tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" \
  /tmp/terminalai_db.sql \
  /opt \
  /etc/nginx/sites-available/terminal-ai \
  /etc/nginx/sites-enabled/terminal-ai \
  $HOME/.ssh 2>/dev/null

# Clean up the temp database dump
rm /tmp/terminalai_db.sql

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}[SUCCESS] User-space backup complete!${NC}"
echo -e "Saved to: ${CYAN}$BACKUP_DIR/$ARCHIVE_NAME${NC}"
echo -e "⚠️  Download this file to your local computer via SFTP before you nuke!"
echo -e "${GREEN}================================================================${NC}"
