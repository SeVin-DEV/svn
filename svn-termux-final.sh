#!/usr/bin/env bash
# ── SVNTERM Termux Automation — Final Stage (Self-Healing) ────
set -e

echo "→ Force-fixing the shell environment..."

export SHELL=/bin/bash
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# 1. Self-Healing: Check if pnpm is broken or missing
if ! command -v pnpm &> /dev/null || pnpm --version 2>&1 | grep -q "MODULE_NOT_FOUND"; then
    echo "→ Detected broken or missing pnpm. Performing emergency repair..."
    rm -rf /usr/local/bin/pnpm
    rm -rf /root/.local/share/pnpm

    # Install standalone binary (no version=latest to avoid 404/Illegal Number)
    curl -fsSL https://get.pnpm.io/install.sh | sh -

    # Force the symbolic link to bypass the .l2s shim bug
    ln -sf /root/.local/share/pnpm/pnpm /usr/local/bin/pnpm
fi

# 2. Verify Fix
echo "→ pnpm version: $(pnpm --version)"

# 3. Persist paths to bashrc so you never have to do this again
if ! grep -q "PNPM_HOME" ~/.bashrc; then
    {
      echo "export SHELL=/bin/bash"
      echo "export PNPM_HOME=\"/root/.local/share/pnpm\""
      echo "export PATH=\"\$PNPM_HOME:\$PATH\""
    } >> ~/.bashrc
fi

# 4. Initialize Node.js Environment
echo "→ Synchronizing Node.js LTS..."
pnpm env use --global lts

# 5. Ensure the Database is actually running
echo "→ Checking PostgreSQL status..."
service postgresql start || pg_ctlcluster 14 main start

echo ""
echo "✓ BRIDGE REPAIRED."
echo "You are now 100% ready to run your main install script."