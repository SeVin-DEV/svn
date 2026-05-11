#!/usr/bin/env bash
set -e

echo "→ Leveling environment (Universal Edition)..."

# 1. Detect installed Postgres version
PG_VER=$(ls /etc/postgresql/ | head -n 1)

if [ -z "$PG_VER" ]; then
    echo "→ Postgres not found. Attempting installation..."
    apt update && apt install -y postgresql postgresql-common
    PG_VER=$(ls /etc/postgresql/ | head -n 1)
fi

# 2. Fix PostgreSQL: Create the cluster if it doesn't exist
if [ ! -d "/var/lib/postgresql/$PG_VER/main" ]; then
    echo "→ Building PostgreSQL $PG_VER cluster..."
    pg_createcluster "$PG_VER" main --start || echo "Cluster exists."
fi

# 3. Start PostgreSQL
echo "→ Starting PostgreSQL..."
service postgresql start || /etc/init.d/postgresql start

# 4. Install pnpm v9 (Node v20 compatible)
echo "→ Installing pnpm v9..."
npm install -g pnpm@9

# 5. Create systemctl shim
echo "→ Creating systemctl shim..."
cat << 'SHIM' > /usr/local/bin/systemctl
#!/usr/bin/env bash
echo "Shim: Pretending to $1 $2..."
exit 0
SHIM
chmod +x /usr/local/bin/systemctl

# 6. Final Verification
echo ""
echo "→ Node version: $(node -v)"
echo "→ pnpm version: $(pnpm -v)"
echo "→ Postgres version: $PG_VER"
echo "✓ PROOT LEVELED. Run 'bash install.sh' now."
