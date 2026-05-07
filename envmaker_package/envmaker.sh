#!/usr/bin/env bash
# ============================================================
#  EnvMaker - Automated Interactive Script Converter
# ============================================================
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

TARGET=$1

if [ -z "$TARGET" ] || [ ! -f "$TARGET" ]; then
    echo -e "${RED}[ERROR] You must provide a valid target script.${NC}"
    echo "Usage: ./envmaker.sh <script_to_modify.sh>"
    exit 1
fi

TARGET_DIR=$(dirname "$TARGET")
ENV_FILE="$TARGET_DIR/.env"

echo -e "${CYAN}━━━ EnvMaker: Scanning ${TARGET} ━━━${NC}"

# 1. Extract variable names from interactive 'read' prompts
# This regex looks for lines containing 'read', flags like '-rp', and grabs the last word (the variable)
VARS=$(grep -E '^[[:space:]]*read.*-[A-Za-z]*[rp]' "$TARGET" | awk '{print $NF}')

if [ -z "$VARS" ]; then
    echo -e "${YELLOW}No interactive prompts found in $TARGET.${NC}"
    exit 0
fi

# 2. Inject the .env loader into the target script (if not already there)
if ! grep -q "source \".env\"" "$TARGET" && ! grep -q "source \"\$(dirname \"\$0\")/.env\"" "$TARGET"; then
    echo -e "${CYAN}→ Injecting .env source loader into script header...${NC}"
    # Inserts the loader right after the bash shebang
    sed -i '2i \n# --- Injected by EnvMaker ---\nif [ -f "$(dirname "$0")/.env" ]; then\n  source "$(dirname "$0")/.env"\nfi\n# --------------------------\n' "$TARGET"
fi

# 3. Create or update the .env file
touch "$ENV_FILE"
echo -e "${CYAN}→ Updating $ENV_FILE...${NC}"

for VAR in $VARS; do
    # Strip any accidental quotes or formatting from the variable name
    VAR=$(echo "$VAR" | tr -d '"'\''')

    # If the variable isn't already in the .env file, add it
    if ! grep -q "^$VAR=" "$ENV_FILE"; then
        echo "$VAR=\"\"" >> "$ENV_FILE"
        echo -e "  ${GREEN}+ Added $VAR to .env${NC}"
    fi

    # 4. Modify the target script to make the prompt conditional!
    # It changes: read -rp "Prompt" VAR
    # To:         [ -z "$VAR" ] && read -rp "Prompt" VAR
    # This means: "If $VAR is empty, THEN ask the user."
    if ! grep -q "\[ -z \"\$$VAR\" \] &&.* $VAR$" "$TARGET"; then
        sed -i "s/^[[:space:]]*read.*[rp].* $VAR$/[ -z \"\$$VAR\" ] \\&\\& &/g" "$TARGET"
    fi
done

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}[SUCCESS] ${TARGET} is now fully automated!${NC}"
echo -e "All detected secrets have been routed to: ${CYAN}${ENV_FILE}${NC}"
echo -e "================================================================${NC}"
echo -e "To run this script hands-free, fill out your secrets by running:"
echo -e "  ${YELLOW}nano ${ENV_FILE}${NC}"
