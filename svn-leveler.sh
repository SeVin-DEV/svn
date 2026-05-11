#!/usr/bin/env bash
set -e

echo "→ Leveling environment (The Final Stand)..."

# 1. System Dependencies
if ! command -v psql &> /dev/null; then
    apt update && apt install -y postgresql postgresql-contrib
fi

# 2. Install pnpm via npm (Most reliable fallback)
echo "→ Installing pnpm via npm..."
npm install -g pnpm || (echo "npm not found. Run: apt install -y nodejs npm" && exit 1)

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
echo "✓ PROOT LEVELED. Run 'bash install.sh' now."