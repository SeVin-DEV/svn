# svnterm.sh

Terminal AI self-host installation script.

This script installs and configures a production Terminal AI deployment on Ubuntu/Debian using:

- Node.js 22
- pnpm
- PM2
- PostgreSQL
- Nginx
- Piper local TTS
- optional Let's Encrypt SSL

## Files

- `svnterm.sh` — self-host installer

## Supported Systems

- Ubuntu 22.04+
- Debian 12+

## Usage

Make executable:

```bash
chmod +x svnterm.sh
```

Run:

```bash
./svnterm.sh
```

or:

```bash
bash svnterm.sh
```

## Information requested during install

The installer asks for:

- GitHub repository URL
- install directory
- domain or server IP
- API server port
- PostgreSQL database name
- PostgreSQL user
- PostgreSQL password
- whether to configure SSL with Let's Encrypt

## Default values

```text
Install directory: /opt/terminal-ai
API port: 3001
Database name: terminalai
Database user: terminalai
```

## What the installer does

### System packages

Installs core dependencies:

```text
curl
git
build-essential
ca-certificates
gnupg
lsb-release
nginx
postgresql
postgresql-contrib
openssl
```

### Piper TTS

Installs Piper to:

```text
/opt/piper
```

Symlinks the binary to:

```text
/usr/local/bin/piper
```

Downloads the `en_US-lessac-medium` voice model.

### Node.js / pnpm / PM2

Installs Node.js 22, pnpm, and PM2.

### PostgreSQL

Creates the selected database and user if they do not already exist.

### Repository deployment

Clones or updates the target GitHub repository into the chosen install directory.

### Environment file

Writes:

```text
.env
```

inside the install directory.

This file contains:

- `NODE_ENV`
- `DATABASE_URL`
- `SESSION_SECRET`
- `PORT`
- `BASE_PATH`

Keep this file private.

### Build process

Runs:

```bash
pnpm install --frozen-lockfile
pnpm --filter @workspace/db run push
pnpm --filter @workspace/terminal-ai run build
pnpm --filter @workspace/api-server run build
```

### PM2

Creates:

```text
ecosystem.config.cjs
```

Then starts or reloads:

```text
terminal-ai-api
```

### Nginx

Creates an Nginx site config at:

```text
/etc/nginx/sites-available/terminal-ai
```

Enables it at:

```text
/etc/nginx/sites-enabled/terminal-ai
```

The config serves the frontend and proxies `/api/` to the backend API server.

### Optional SSL

If selected, installs Certbot and requests a Let's Encrypt certificate for the provided domain.

## Generated update script

The installer writes:

```text
update.sh
```

inside the install directory.

Use it later with:

```bash
bash /opt/terminal-ai/update.sh
```

or with your chosen install path.

## Important notes

- The pasted heredoc wrapper was removed from this packaged version.
- The actual downloadable file starts directly with:
  ```bash
  #!/usr/bin/env bash
  ```
- The file is named `svnterm.sh`.
- The script comment says `Usage: bash install.sh`; if you want consistency, use:
  ```bash
  bash svnterm.sh
  ```
- Your `.env` file will contain sensitive database and session secret values.
