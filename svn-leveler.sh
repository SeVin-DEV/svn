#!/usr/bin/env bash
set -e

echo "→ Clearing old junk..."
rm -f /usr/local/bin/pnpm /usr/local/bin/systemctl

# 1. Download and Extract with "Search and Rescue" logic
echo "→ Fetching latest pnpm ARM64..."
curl -fsSL https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linux-arm64.tar.gz -o /tmp/pnpm.tar.gz

echo "→ Extracting and finding the binary..."
mkdir -p /tmp/pnpm-fix
tar -xzf /tmp/pnpm.tar.gz -C /tmp/pnpm-fix

# This looks for the actual 'pnpm' file anywhere in the extracted folder
PNPM_BIN=$(find /tmp/pnpm-fix -name "pnpm-linux-arm64" -o -name "pnpm" -type f | head -n 1)

if [ -z "$PNPM_BIN" ]; then
    echo "× Error: Could not find the pnpm binary in the download."
    exit 1
fi

mv "$PNPM_BIN" /usr/local/bin/pnpm
chmod +x /usr/local/bin/pnpm
rm -rf /tmp/pnpm.tar.gz /tmp/pnpm-fix

# 2. Re-create the systemctl "Liar" shim
echo "→ Creating systemctl shim..."
cat << 'SHIM' > /usr/local/bin/systemctl
#!/usr/bin/env bash
echo "Shim: Pretending to $1 $2..."
exit 0
SHIM
chmod +x /usr/local/bin/systemctl

# 3. Start PostgreSQL
echo "→ Starting PostgreSQL..."
service postgresql start || pg_ctlcluster 14 main start

# 4. Export environment
export SHELL=/bin/bash
export PATH="/usr/local/bin:$PATH"

echo ""
echo "→ Verification: $(pnpm --version)"
echo "✓ PROOT LEVELED."