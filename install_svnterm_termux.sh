#!/usr/bin/env bash
set -e

# 1. Clone the repository if it doesn't exist
INSTALL_DIR="/opt/terminal-ai"
if [ ! -d "$INSTALL_DIR" ]; then
  echo "→ Cloning SVNTERM..."
    git clone https://github.com/sevin-dev/svnterm.git "$INSTALL_DIR"
    fi
    cd "$INSTALL_DIR"

    # 2. Configure Environment Variables
    # Using local DB and correct ARM64 paths
    echo "→ Configuring .env..."
    cat << ENVEOF > .env
    DATABASE_URL=postgres://postgres:postgres@localhost:5432/terminalai
    PORT=3001
    PIPER_BINARY=/usr/local/bin/piper
    PIPER_MODEL=/opt/piper/en_US-lessac-medium.onnx
    NODE_ENV=production
    ENVEOF

    # 3. Fix the Piper TTS Binary (Crucial for Pixel/ARM64)
    # The repo's default PIPER_INSTALL.md uses x86_64; we need aarch64
    echo "→ Installing ARM64 Piper TTS..."
    mkdir -p /opt/piper
    curl -fsSL https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_aarch64.tar.gz \
      | tar -xzf - -C /opt/piper --strip-components=1
      ln -sf /opt/piper/piper /usr/local/bin/piper

      # 4. Monorepo Installation and Build
      echo "→ Installing dependencies..."
      pnpm install

      echo "→ Building system components..."
      pnpm --filter @workspace/api-spec run codegen
      pnpm --filter @workspace/db run migrate
      pnpm run build

      # 5. Background Service Management
      echo "→ Starting background services via PM2..."
      npm install -g pm2
      pm2 start ecosystem.config.cjs
      pm2 save

      echo "✓ SVNTERM is installed and active at http://localhost:3001"
    
   