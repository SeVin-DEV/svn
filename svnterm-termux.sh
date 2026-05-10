#!/usr/bin/env bash

set -e



echo "Updating system and installing base dependencies..."

apt update && apt install -y curl git build-essential python3 libvips-dev postgresql postgresql-contrib



# 1. Install pnpm and Node.js

echo "Installing pnpm and Node.js..."

curl -fsSL https://get.pnpm.io/install.sh | sh -

export PNPM_HOME="$HOME/.local/share/pnpm"

export PATH="$PNPM_HOME:$PATH"

pnpm env use --global lts



# 2. Setup PostgreSQL (Local Proot Mode)

echo "Starting PostgreSQL..."

service postgresql start

sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

sudo -u postgres createdb terminalai || echo "Database already exists"



# 3. ARM64 Piper Prep (Crucial for Pixel)

echo "Preparing ARM64 Piper directory..."

mkdir -p /opt/piper

# We download the aarch64 binary instead of the x86_64 version in the docs

curl -fsSL https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_aarch64.tar.gz \

  | tar -xzf - -C /opt/piper --strip-components=1

  ln -sf /opt/piper/piper /usr/local/bin/piper



  echo "Pre-install complete. You are ready to clone and run install"