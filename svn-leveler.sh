#!/usr/bin/env bash
set -e

echo "→ Leveling environment for standard install.sh..."

# 1. Clean up
rm -f /usr/local/bin/pnpm /usr/local/bin/systemctl

# 2. Download and Extract the ARM64 binary
# We pull the tarball, extract it, and move the binary to /usr/local/bin
echo "→ Downloading latest pnpm ARM64 tarball..."
curl -fsSL https://github.com/pnpm/pnpm/releases/latest/download/pnpm-linux-arm64.tar.gz -o /tmp/pnpm.tar.gz

echo "→ Extracting pnpm..."
tar -xzf /tmp/pnpm.tar.gz -C /tmp
mv /tmp/pnpm-linux-arm64 /usr/local/bin/pnpm
chmod +x /usr/local/bin/pnpm
rm /tmp/pnpm.tar.gz

# 3. Create systemctl shim (The installer trick)
echo "→ Creating systemctl shim..."
cat << 'SHIM' > /usr/local/bin/systemctl
#!/usr/bin/env bash
echo "Shim: Pretending to $1 $2..."
exit 0
SHIM
chmod +x /usr/local/bin/systemctl

# 4. Start PostgreSQL manually
echo "→ Starting PostgreSQL service..."
service postgresql start || pg_ctlcluster 14 main start

# 5. Export environment
export SHELL=/bin/bash
export PATH="/usr/local/bin:$PATH"

echo "→ pnpm version: $(pnpm --version)"
echo "✓ Environment leveled. Run 'bash install.sh' now."