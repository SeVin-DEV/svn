#!/usr/bin/env bash
# ── SVNTERM Environment Leveler ──────────────────────────────
# Run this to make your Termux-Ubuntu feel like a standard server.
set -e

echo "→ Cleaning up previous failed links..."
rm -f /usr/local/bin/pnpm /usr/local/bin/systemctl

# 1. Install a standalone ARM64 pnpm (The "Hoopla" Killer)
echo "→ Installing standalone ARM64 pnpm..."
curl -fsSL https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linux-arm64 -o /usr/local/bin/pnpm
chmod +x /usr/local/bin/pnpm

# 2. Fake 'systemctl' to prevent install.sh from crashing
# This allows the script to 'start' services without throwing errors
echo "→ Creating systemctl shim..."
cat << 'EOF' > /usr/local/bin/systemctl
#!/usr/bin/env bash
echo "Shim: Pretending to $1 $2..."
exit 0
EOF
chmod +x /usr/local/bin/systemctl

# 3. Ensure the Database is actually running for the install
echo "→ Starting PostgreSQL..."
service postgresql start || pg_ctlcluster 14 main start

# 4. Final Environment Variables
export SHELL=/bin/bash
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

echo "→ pnpm version: $(pnpm --version)"
echo "✓ Environment leveled. You can now run 'bash install.sh' from your repo."
