#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━ Oracle Cloud Infrastructure (OCI) CLI Setup ━━━${NC}"
echo -e "${CYAN}→ Downloading and running the official OCI installer...${NC}"

# Run the official Oracle installation script silently
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults

echo -e "${GREEN}[+] Installation complete.${NC}"
echo -e "${CYAN}→ Launching Interactive OCI Configuration...${NC}"
echo -e "You will need your User OCID, Tenancy OCID, and Region."
echo "------------------------------------------------------------"

# Bypass the un-refreshed $PATH by calling the binary's exact location directly
~/bin/oci setup config

echo -e "------------------------------------------------------------"
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}[SUCCESS] OCI CLI installed and configured!${NC}"
echo -e "${CYAN}→ Refreshing your terminal session now...${NC}"
echo -e "${GREEN}================================================================${NC}"

# This MUST be the last line. It destroys the script process and replaces it with a fresh terminal.
exec -l $SHELL
