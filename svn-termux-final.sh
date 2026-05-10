#!/usr/bin/env bash
set -e

# 1. Clean environment
export SHELL=/bin/bash
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

echo "→ Checking for pnpm..."

if ! command -v pnpm &> /dev/null; then
    echo "→ pnpm not found. Installing latest stable version..."
    # Do NOT use 'env PNPM_VERSION=latest' as it breaks the script
    curl -fsSL https://get.pnpm.io/install.sh | sh -

    # Ensure it is linked for this session
    ln -sf "$PNPM_HOME/pnpm" /usr/local/bin/pnpm
fi

# 2. Finalize Node.js environment
echo "→ Synchronizing Node.js LTS..."
pnpm env use --global lts

# 3. Ensure database is active
service postgresql start || pg_ctlcluster 14 main start

echo "✓ Ready to rock. Proceed with 'bash install_svnterm_termux.sh'."