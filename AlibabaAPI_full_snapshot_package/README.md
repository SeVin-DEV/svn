# full_snapshot.sh

Alibaba Cloud ECS full server snapshot automation utility.

This script automatically:

- installs the Alibaba Cloud CLI if missing
- checks API credential configuration
- retrieves ECS instance metadata
- identifies the system disk
- creates a full Alibaba Cloud snapshot through the ECS API

The snapshot operation occurs remotely within Alibaba Cloud infrastructure and continues in the background after initiation.

## Files

- `full_snapshot.sh` — automated Alibaba ECS snapshot utility

## Requirements

Target environment:

- Ubuntu/Debian-based Linux server
- Alibaba Cloud ECS instance
- internet access
- sudo privileges

Required tools:

- curl
- wget
- tar
- jq
- aliyun CLI

The script auto-installs:

- Alibaba Cloud CLI
- jq (if missing)

## Usage

Make executable:

```bash
chmod +x full_snapshot.sh
```

Run:

```bash
./full_snapshot.sh
```

## What the script does

### 1. Installs Alibaba Cloud CLI

If `aliyun` is not already installed:

```bash
wget https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz
```

Then moves the binary into:

```text
/usr/local/bin/
```

### 2. Ensures jq exists

Installs jq using:

```bash
sudo apt-get install -y jq
```

### 3. Verifies Alibaba API credentials

Checks:

```bash
aliyun configure get
```

If credentials are missing, the script exits.

Configure manually using:

```bash
aliyun configure
```

You will need:

- AccessKey ID
- AccessKey Secret
- default region

## ECS Metadata Queries

The script queries Alibaba's internal metadata service:

```text
http://100.100.100.200/latest/meta-data/
```

It retrieves:

- region ID
- ECS instance ID

## Disk Discovery

The script queries ECS APIs to identify the attached system disk:

```bash
aliyun ecs DescribeDisks
```

## Snapshot Creation

Creates a snapshot using:

```bash
aliyun ecs CreateSnapshot
```

Snapshot naming format:

```text
SVNTerm-Pristine-YYYYMMDD-HHMMSS
```

Example:

```text
SVNTerm-Pristine-20260506-143501
```

## Notes

- Snapshot creation is asynchronous.
- The server can continue running during snapshot creation.
- Snapshot completion time depends on disk size and Alibaba backend load.
- Snapshot visibility may take a few minutes to appear in the Alibaba console.

## Suggested Safety Practices

Before large updates or migrations:

1. Run:
   ```bash
   ./full_snapshot.sh
   ```

2. Wait until the snapshot appears in Alibaba ECS console.

3. Proceed with:
   - upgrades
   - deployments
   - destructive maintenance
   - server migrations

## Recovery

Snapshots can later be used to:

- roll back the ECS disk
- clone a server
- create a replacement instance
- recover from failed deployments
