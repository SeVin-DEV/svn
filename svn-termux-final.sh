#!/usr/bin/env bash
# ── SVNTERM Termux Automation — Final Stage (Revised) ─────────
set -e

echo "→ Searching for pnpm binary..."

# Brute force search if standard paths fail
FOUND_PNPM=$(find / -name pnpm -type f -executable 2>/dev/null | head -n 1)

if [ -z "$FOUND_PNPM" ]; then
    echo "× Error: pnpm binary not found on system. Re-run preflight."
    exit 1
fi

echo "→ Found pnpm at: $FOUND_PNPM"
PNPM_DIR=$(dirname "$FOUND_PNPM")

# 1. Export variables for current session
export SHELL=/bin/bash
export PNPM_HOME="$PNPM_DIR"
export PATH="$PNPM_DIR:$PATH"

# 2. Force-link to /usr/local/bin for global access
ln -sf "$FOUND_PNPM" /usr/local/bin/pnpm

# 3. Persist for future logins
{
  echo "export SHELL=/bin/bash"
  echo "export PNPM_HOME=\"$PNPM_DIR\""
  echo "export PATH=\"\$PNPM_HOME:\$PATH\""
} >> ~/.bashrc

# 4. Verify and initialize Node.js
if command -v pnpm &> /dev/null; then
    echo "→ pnpm active. Setting up Node environment..."
    pnpm setup
    pnpm env use --global lts
else
    echo "× Error: pnpm link failed. Check permissions."
    exit 1
fi

# 5. Ensure database is active
service postgresql start || pg_ctlcluster 14 main start

echo "✓ Environment ready. Proceed with main install."