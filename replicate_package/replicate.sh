#!/usr/bin/env bash
# ============================================================
#  replicate.sh — Dynamic Server Replication Packager
# ============================================================
set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}━━━ Launching Server Replication Packager ━━━${NC}"

# 1. Determine the source variable identifier
DEFAULT_IDENTIFIER=$(hostname)
read -rp "$(echo -e "Enter source clone identifier [${YELLOW}${DEFAULT_IDENTIFIER}${NC}]: ")" CLONE_ID
CLONE_ID="${CLONE_ID:-$DEFAULT_IDENTIFIER}"
# Sanitize filename (remove spaces/special characters)
CLONE_ID=$(echo "$CLONE_ID" | tr -cd 'A-Za-z0-9_-')

OUTPUT_SCRIPT="deploy_${CLONE_ID}.sh"

# 2. Create a clean temporary workspace
WORKSPACE="/tmp/server_clone_workspace"
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE/files"

# 3. Dump the current PostgreSQL Database
echo "→ Dumping PostgreSQL database..."
sudo -u postgres pg_dump terminalai > "$WORKSPACE/files/terminalai_db.sql"

# 4. Archive application files, Nginx configurations, and user SSH keys
echo "→ Archiving application state and system configs..."
tar -czf "$WORKSPACE/files/app_data.tar.gz" \
  /opt/terminal-ai \
    /etc/nginx/sites-available/terminal-ai \
      $HOME/.ssh 2>/dev/null

      # 5. Generate the target deployment engine template
      cat << 'EOF' > "$WORKSPACE/deploy_template.sh"
      #!/usr/bin/env bash
      # ============================================================
      #  deploy_(*).sh — Automated Target Server Deployment
      # ============================================================
      set -euo pipefail

      RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'

      echo -e "${CYAN}━━━ Starting Server Clone Deployment ━━━${NC}"

      # 1. Install core system packages
      echo "→ Synchronizing system repositories and baseline packages..."
      sudo apt-get update -qq
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        curl git build-essential nginx postgresql postgresql-contrib openssl tmux jq ufw

        # 2. Extract embedded package assets from the trailing binary payload
        echo "→ Unpacking core application archives..."
        PAYLOAD_LINE=$(grep -a -n '^__PAYLOAD_BELOW__' "$0" | cut -d ':' -f 1)
        tail -n +$((PAYLOAD_LINE + 1)) "$0" | tar -xz -C /tmp/

        # 3. Overwrite directory hierarchies cleanly onto system root
        sudo tar -xzf /tmp/app_data.tar.gz -C /

        # 4. Verify/Install Piper TTS binary and default vocal layout
        if [ ! -f "/usr/local/bin/piper" ]; then
            echo "→ Provisioning Piper local neural TTS tools..."
                sudo mkdir -p /opt/piper
                    curl -fsSL "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz" -o /tmp/piper.tar.gz
                        sudo tar -xzf /tmp/piper.tar.gz -C /opt/piper --strip-components=1
                            sudo ln -sf /opt/piper/piper /usr/local/bin/piper
                                
                                    VOICE_BASE="https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/lessac/medium"
                                        sudo curl -fsSL "${VOICE_BASE}/en_US-lessac-medium.onnx" -o /opt/piper/en_US-lessac-medium.onnx
                                            sudo curl -fsSL "${VOICE_BASE}/en_US-lessac-medium.onnx.json" -o /opt/piper/en_US-lessac-medium.onnx.json
                                            fi

                                            # 5. Bring in Node environment binaries and dependency management flags
                                            if ! command -v node &>/dev/null; then
                                              curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
                                                sudo apt-get install -y nodejs
                                                  sudo npm install -g pnpm pm2
                                                  fi

                                                  # 6. Reconstruct PostgreSQL instance properties matching parsed .env specs
                                                  sudo systemctl enable --now postgresql

                                                  DB_URL=$(grep '^DATABASE_URL=' /opt/terminal-ai/.env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
                                                  DB_USER=$(echo "$DB_URL" | sed -e 's|postgresql://||' -e 's|:.*||')
                                                  DB_PASS=$(echo "$DB_URL" | sed -e 's|postgresql://[^:]*:||' -e 's|@.*||')
                                                  DB_NAME=$(echo "$DB_URL" | sed 's|.*/||')

                                                  sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'" | grep -q 1 || \
                                                    sudo -u postgres psql -c "CREATE USER \"${DB_USER}\" WITH PASSWORD '${DB_PASS}';"
                                                    sudo -u postgres psql -c "DROP DATABASE IF EXISTS \"${DB_NAME}\";"
                                                    sudo -u postgres psql -c "CREATE DATABASE \"${DB_NAME}\" OWNER \"${DB_USER}\";"
                                                    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"${DB_NAME}\" TO \"${DB_USER}\";"

                                                    # Restore database tables from snapshot dump
                                                    sudo -u postgres psql "$DB_NAME" < /tmp/terminalai_db.sql
                                                    rm -f /tmp/terminalai_db.sql

                                                    # 7. Dynamically adjust system routing headers for the new server network address
                                                    read -rp "Enter the new Domain or IP for this recipient server instance: " NEW_DOMAIN
                                                    sudo sed -i "s/server_name .*/server_name ${NEW_DOMAIN};/" /etc/nginx/sites-available/terminal-ai
                                                    sudo ln -sf /etc/nginx/sites-available/terminal-ai /etc/nginx/sites-enabled/terminal-ai
                                                    sudo rm -f /etc/nginx/sites-enabled/default

                                                    # 8. Firewall validation and service ignition
                                                    sudo ufw allow OpenSSH && sudo ufw allow 80 && sudo ufw allow 443
                                                    sudo ufw --force enable

                                                    sudo systemctl restart nginx
                                                    cd /opt/terminal-ai
                                                    pm2 reload ecosystem.config.cjs --update-env || pm2 start ecosystem.config.cjs
                                                    pm2 save

                                                    echo -e "${GREEN}[SUCCESS] Targeted environment cloning sequence finished successfully!${NC}"
                                                    echo -e "Your application mirror is active at: http://${NEW_DOMAIN}"
                                                    exit 0

                                                    __PAYLOAD_BELOW__
                                                    EOF

                                                    # 6. Stitch template layout and source binary payload together
                                                    echo "→ Injecting system snapshot payload into final deployment runner..."
                                                    mv "$WORKSPACE/deploy_template.sh" "./$OUTPUT_SCRIPT"
                                                    tar -cz -C "$WORKSPACE/files" . >> "./$OUTPUT_SCRIPT"
                                                    chmod +x "$OUTPUT_SCRIPT"

                                                    # Clean up workspace entries
                                                    rm -rf "$WORKSPACE"

                                                    echo -e "${GREEN}================================================================${NC}"
                                                    echo -e "${GREEN}[SUCCESS] Portable system clone package built!${NC}"
                                                    echo -e "File generated: ${CYAN}./${OUTPUT_SCRIPT}${NC}"
                                                    echo -e "Copy this single file over to the destination server and execute it."
                                                    echo -e "${GREEN}================================================================${NC}"