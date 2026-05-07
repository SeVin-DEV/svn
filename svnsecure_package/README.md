# svnsecure.sh

Server initialization and dependency hardening utility for Ubuntu/Debian ECS instances.

This script prepares a fresh Linux server for development and deployment work by:

- updating system packages
- installing compilation dependencies
- installing terminal utilities
- configuring UFW firewall access for SSH

Intended as a first-run bootstrap script before deploying svnterm or related infrastructure.

## Files

- `svnsecure.sh` — server preparation and dependency bootstrap script

## Supported Systems

- Ubuntu 22.04+
- Debian 12+
- Other apt-based Debian derivatives may work

## Usage

Make executable:

```bash
chmod +x svnsecure.sh
```

Run:

```bash
./svnsecure.sh
```

## What the script installs

### Build & Development Dependencies

```text
build-essential
pkg-config
libssl-dev
zlib1g-dev
libffi-dev
libbz2-dev
libreadline-dev
libsqlite3-dev
```

These packages help prevent common:
- native module build failures
- crypto compilation errors
- Python/Rust/C/C++ dependency issues

## Terminal Utility Stack

```text
tmux
jq
htop
net-tools
curl
wget
unzip
tar
tree
```

## Firewall Configuration

The script installs and enables:

```text
ufw
```

Then automatically allows:

```text
OpenSSH
```

before enabling the firewall to avoid accidental lockout.

## Notes

- The script uses:
  ```bash
  set -e
  ```
  so execution stops immediately if a command fails.

- Commands run non-interactively where possible.

- Intended for clean server initialization before:
  - Node.js deployments
  - PM2 services
  - pnpm installs
  - database setup
  - AI/self-host stacks

## Suggested Workflow

1. Provision fresh ECS/VPS instance
2. Run:
   ```bash
   ./svnsecure.sh
   ```
3. Reboot if desired
4. Continue with:
   - Git setup
   - deployment scripts
   - svnterm installer
