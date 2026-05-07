# backup.sh

Terminal AI backup and snapshot utility.

This script creates a compressed backup archive containing:

- PostgreSQL database dump
- `/opt` application files
- Nginx site configuration
- user SSH keys/configuration

The resulting archive is intended for migration, disaster recovery, or server rebuild workflows.

## Files

- `backup.sh` — backup automation script

## Requirements

The target server should include:

- Bash
- PostgreSQL tools (`pg_dump`)
- tar
- sudo access

Expected database:

```text
terminalai
```

Expected application install location:

```text
/opt
```

## Usage

Make executable:

```bash
chmod +x backup.sh
```

Run:

```bash
./backup.sh
```

## Output

Backups are stored in:

```text
/root/backups
```

Archive naming format:

```text
svnterm_data_YYYYMMDD_HHMMSS.tar.gz
```

Example:

```text
svnterm_data_20260506_142500.tar.gz
```

## What gets backed up

### PostgreSQL Database

The script creates:

```bash
/tmp/terminalai_db.sql
```

using:

```bash
pg_dump terminalai
```

### Application & Configuration Files

Included paths:

```text
/opt
/etc/nginx/sites-available/terminal-ai
/etc/nginx/sites-enabled/terminal-ai
$HOME/.ssh
```

## Archive Creation

The archive is compressed using:

```bash
tar -czf
```

## Cleanup

Temporary SQL dump is removed automatically after archive creation.

## Suggested Recovery Workflow

1. Run `backup.sh`
2. Download archive locally via:
   - SFTP
   - SCP
   - rsync
3. Rebuild or replace server
4. Upload archive to new server
5. Run corresponding `restore.sh`

## Notes

- The script captures the entire `/opt` directory.
- SSH keys are included for Git/GitHub continuity.
- Backup archives may contain sensitive credentials and private keys.
- Store backup archives securely.
