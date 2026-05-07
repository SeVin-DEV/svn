# alibabaAPI.sh

Alibaba Cloud CLI (`aliyun`) installer and configuration helper.

This script downloads and installs the Alibaba Cloud CLI if missing, then launches the interactive credential configuration process.

## Files

- `alibabaAPI.sh` — Alibaba Cloud CLI bootstrap utility

## Usage

Make executable:

```bash
chmod +x alibabaAPI.sh
```

Run:

```bash
./alibabaAPI.sh
```

## What the script does

### 1. Checks for existing aliyun CLI

Verifies whether:

```bash
aliyun
```

already exists on the system.

### 2. Downloads Alibaba Cloud CLI

Downloads the latest AMD64 Linux release from:

```text
https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz
```

### 3. Extracts and installs

Extracts the binary and installs it globally to:

```text
/usr/local/bin/
```

using:

```bash
sudo mv aliyun /usr/local/bin/
```

### 4. Launches interactive configuration

Runs:

```bash
aliyun configure
```

You will need:

- AccessKey ID
- AccessKey Secret
- Region ID

## Example region IDs

```text
us-east-1
cn-hangzhou
ap-southeast-1
```

## Example command after setup

```bash
aliyun ecs DescribeInstances
```

## Notes

- The outer heredoc wrapper was removed from the packaged version.
- The actual script starts directly with:
  ```bash
  #!/usr/bin/env bash
  ```
- Requires:
  - bash
  - wget
  - tar
  - sudo privileges
  - internet access
- Intended for Linux AMD64 environments.

## Common use cases

- ECS management
- snapshot automation
- VM provisioning
- infrastructure scripting
- Resource Manager automation
- Alibaba cloud API workflows
