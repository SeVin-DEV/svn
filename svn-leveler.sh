#!/usr/bin/env bash
set -e

echo "→ Leveling environment (Corepack Edition)..."

# 1. System Dependencies
if ! command -v psql &> /dev/null; then
    apt update && apt install -y postgresql postgresql-contrib
fi

# 2. Fix pnpm using Corepack (Built-in Node manager)
echo "→ Activating pnpm via Corepack..."
rm -f /usr/local/bin/pnpm
corepack enable
corepack prepare pnpm@latest --activate

# 3. Create systemctl shim
echo "→ Creating systemctl shim..."
cat << 'SHIM' > /usr/local/bin/systemctl
#!/usr/bin/env bash
echo "Shim: Pretending to $1 $2..."
exit 0
SHIM
chmod +x /usr/local/bin/systemctl

# 4. Start PostgreSQL
echo "→ Starting PostgreSQL..."
service postgresql start || /etc/init.d/postgresql start

echo ""
echo "→ Verification: $(pnpm --version)"
echo "✓ PROOT LEVELED. You are ready for 'bash install.sh'."