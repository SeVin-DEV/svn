# restore.sh

Terminal AI application restore and recovery utility.

This script restores a previously created application snapshot archive, restores the PostgreSQL database, reloads PM2-managed services, and reloads Nginx.

## Files

- `restore.sh` — restoration automation script

## Requirements

Target environment should include:

- Bash
- tar
- PostgreSQL (`psql`)
- sudo access
- PM2
- systemd
- Nginx

Expected application path:

```text
/opt/terminal-ai
```

Expected database:

```text
terminalai
```

## Usage

Make executable:

```bash
chmod +x restore.sh
```

Run restore:

```bash
./restore.sh /path/to/svnterm_data_XXXXX.tar.gz
```

## What the script does

### 1. Extracts backup archive

The archive is extracted directly to the filesystem root:

```bash
tar -xzf "$ARCHIVE" -C /
```

This overwrites the fresh installation with the backed-up application data.

### 2. Restores PostgreSQL database

The script:

- drops the existing `terminalai` database
- recreates it
- imports `/tmp/terminalai_db.sql`

Commands used:

```bash
DROP DATABASE IF EXISTS terminalai;
CREATE DATABASE terminalai OWNER terminalai;
```

### 3. Reloads services

The script reloads PM2-managed services:

```bash
pm2 reload ecosystem.config.cjs --update-env
```

If reload fails, it attempts:

```bash
pm2 start ecosystem.config.cjs
```

Then reloads Nginx:

```bash
systemctl reload nginx
```

## Important Notes

- This script modifies system files and databases.
- It should only be run on the intended target server.
- Existing application data will be overwritten.
- Requires sufficient permissions to:
  - extract files into `/`
  - manage PostgreSQL
  - reload system services

## Suggested Workflow

1. Fresh install server
2. Upload backup archive
3. Run:

```bash
./restore.sh your_backup.tar.gz
```

4. Verify:
   - PM2 status
   - Nginx status
   - database connectivity
   - frontend/backend operation
