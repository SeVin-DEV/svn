#!/usr/bin/env bash
set -e

echo "→ Checking for missing system dependencies..."

# 1. Install Postgres if it's missing (Fixes the 'unrecognized service' error)
if ! command -v psql &> /dev/null; then
    echo "→ Installing PostgreSQL engine..."
    apt update && apt install -y postgresql postgresql-contrib
fi

echo "→ Clearing old junk..."
rm -f /usr/local/bin/pnpm /usr/local/bin/systemctl

# 2. Fetch and extract pnpm ARM64
echo "→ Fetching latest pnpm ARM64..."
curl -fsSL https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linux-arm64.tar.gz -o /tmp/pnpm.tar.gz

echo "→ Extracting and finding the binary..."
mkdir -p /tmp/pnpm-fix
tar -xzf /tmp/pnpm.tar.gz -C /tmp/pnpm-fix

PNPM_BIN=$(find /tmp/pnpm-fix -name "pnpm-linux-arm64" -o -name "pnpm" -type f | head -n 1)

mv "$PNPM_BIN" /usr/local/bin/pnpm
chmod +x /usr/local/bin/pnpm
rm -rf /tmp/pnpm.tar.gz /tmp/pnpm-fix

# 3. Create the systemctl shim (The installer trick)
echo "→ Creating systemctl shim..."
cat << 'SHIM' > /usr/local/bin/systemctl
#!/usr/bin/env bash
echo "Shim: Pretending to $1 $2..."
exit 0
SHIM
chmod +x /usr/local/bin/systemctl

# 4. Start PostgreSQL manually (Fixed for Proot)
echo "→ Starting PostgreSQL..."
# Proot sometimes uses 'pg_ctl' instead of 'service'
if [ -d "/etc/postgresql" ]; then
    service postgresql start || /etc/init.d/postgresql start || echo "Warning: Manual start required."
else
    echo "× Error: Postgres config not found. Re-run apt install."
    exit 1
fi

# 5. Export environment
export SHELL=/bin/bash
export PATH="/usr/local/bin:$PATH"

echo ""
echo "→ Verification: pnpm $(pnpm --version)"
echo "✓ PROOT LEVELED."