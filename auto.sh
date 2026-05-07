#!/usr/bin/env bash
# ============================================================
#  Auto-Deploy Orchestrator (with Integrated EnvMaker)
# ============================================================
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}━━━ The Auto-Deploy Orchestrator ━━━${NC}"

# 1. Ask for the Source (Local Dir or GitHub Repo)
read -rp "Enter the local directory path OR a GitHub repo URL: " SOURCE

if [ -z "$SOURCE" ]; then
    echo -e "${RED}[ERROR] Source cannot be empty.${NC}"
    exit 1
fi

TARGET_DIR=""

# Determine if it's a repo or local
if [[ "$SOURCE" == http* ]] || [[ "$SOURCE" == git@* ]]; then
    # Extract repo name for the folder
    REPO_NAME=$(basename "$SOURCE" .git)
    TARGET_DIR="./$REPO_NAME"

    if [ -d "$TARGET_DIR" ]; then
        echo -e "${YELLOW}→ Directory $TARGET_DIR already exists. Pulling latest updates...${NC}"
        git -C "$TARGET_DIR" pull
    else
        echo -e "${CYAN}→ Cloning repository...${NC}"
        git clone "$SOURCE" "$TARGET_DIR"
    fi
else
    # It's a local directory
    TARGET_DIR="$SOURCE"
    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}[ERROR] Local directory does not exist: $TARGET_DIR${NC}"
        exit 1
    fi
fi

# Convert to absolute path
TARGET_DIR=$(realpath "$TARGET_DIR")
ENV_FILE="$TARGET_DIR/.env"

echo -e "\n${CYAN}━━━ Phase 1: EnvMaker Scanning ━━━${NC}"
touch "$ENV_FILE"
NEW_SECRETS_ADDED=0

# Loop through all .sh files in the target directory
for script in "$TARGET_DIR"/*.sh; do
    # Skip this orchestrator script if it happens to be in the folder
    [[ "$(basename "$script")" == "auto.sh" ]] && continue

    # Skip if no .sh files found
    [ -e "$script" ] || continue 

    echo -e "${CYAN}→ Scanning $(basename "$script")...${NC}"

    # Extract variable names from interactive 'read' prompts
    VARS=$(grep -E '^[[:space:]]*read.*-[A-Za-z]*[rp]' "$script" | awk '{print $NF}' || true)

    if [ -n "$VARS" ]; then
        # Inject the .env loader into the script header
        if ! grep -q "source \".env\"" "$script" && ! grep -q "source \"\$(dirname \"\$0\")/.env\"" "$script"; then
            sed -i '2i \n# --- Injected by Auto-Orchestrator ---\nif [ -f "$(dirname "$0")/.env" ]; then\n  source "$(dirname "$0")/.env"\nfi\n# -------------------------------------\n' "$script"
        fi

        for VAR in $VARS; do
            # Strip quotes/garbage
            VAR=$(echo "$VAR" | tr -d '"\'')

            # Append to .env if it doesn't exist
            if ! grep -q "^$VAR=" "$ENV_FILE"; then
                echo "$VAR=\"\"" >> "$ENV_FILE"
                echo -e "  ${GREEN}+ Added $VAR to .env${NC}"
                NEW_SECRETS_ADDED=1
            fi

            # Make the prompt conditional in the target script
            if ! grep -q "\[ -z \"\$$VAR\" \] &&.* $VAR$" "$script"; then
                sed -i "s/^[[:space:]]*read.*[rp].* $VAR$/[ -z \"\$$VAR\" ] \\&\\& &/g" "$script"
            fi
        done
    fi
    # Make sure the script is executable
    chmod +x "$script"
done

echo -e "\n${CYAN}━━━ Phase 2: Configuration Check ━━━${NC}"

# Check if there are unfilled secrets (lines ending with ="")
if grep -q '=""$' "$ENV_FILE"; then
    echo -e "${YELLOW}[ATTENTION] You have unfilled secrets in your .env file!${NC}"
    echo -e "The installer cannot proceed until these are filled out."
    echo -e "\n${BOLD}Action Required:${NC}"
    echo -e "  1. Run: ${CYAN}nano $ENV_FILE${NC}"
    echo -e "  2. Fill inside the quotes for all empty variables."
    echo -e "  3. Re-run this orchestrator: ${CYAN}./auto.sh${NC}"
    exit 0
fi

if [ "$NEW_SECRETS_ADDED" -eq 1 ]; then
    # Edge case: We added secrets, but they had defaults or didn't end in exactly ="". Just in case.
    echo -e "${YELLOW}[ATTENTION] New variables were added to the .env file.${NC}"
    echo -e "Please verify them: ${CYAN}nano $ENV_FILE${NC}"
    echo -e "Re-run this orchestrator when ready."
    exit 0
fi

echo -e "${GREEN}✓ All secrets are populated!${NC}"

echo -e "\n${CYAN}━━━ Phase 3: Execution ━━━${NC}"
echo -e "Executing scripts in alphabetical order...\n"

for script in "$TARGET_DIR"/*.sh; do
    [[ "$(basename "$script")" == "auto.sh" ]] && continue
    [ -e "$script" ] || continue

    echo -e "${BLUE}▶ Running $(basename "$script")...${NC}"

    # Execute the script
    bash "$script"

    echo -e "${GREEN}✓ $(basename "$script") finished.${NC}\n"
done

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}[SUCCESS] All scripts have been successfully deployed!${NC}"
echo -e "${GREEN}================================================================${NC}"
