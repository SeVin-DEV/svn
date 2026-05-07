# oracleAPI.sh

Oracle Cloud Infrastructure (OCI) CLI installer and configuration helper.

This script downloads the official Oracle OCI CLI installer, performs a default installation, launches interactive OCI configuration, and refreshes the shell session afterward.

## Files

- `oracleAPI.sh` — OCI CLI bootstrap and configuration utility

## Usage

Make executable:

```bash
chmod +x oracleAPI.sh
```

Run:

```bash
./oracleAPI.sh
```

## What the script does

### 1. Downloads and installs OCI CLI

Uses Oracle's official installer:

```bash
https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
```

Runs with:

```bash
--accept-all-defaults
```

This performs a mostly unattended install.

## OCI CLI install location

The installer typically places binaries in:

```text
~/bin/oci
```

## Interactive OCI configuration

After installation, the script launches:

```bash
~/bin/oci setup config
```

You will need:

- User OCID
- Tenancy OCID
- Region
- API signing key information

## Terminal refresh

At the end, the script runs:

```bash
exec -l $SHELL
```

This replaces the current shell session with a fresh login shell so the updated PATH and environment variables are immediately available.

## Notes

- The outer heredoc wrapper was removed in the packaged version.
- The downloadable script starts directly with:
  ```bash
  #!/usr/bin/env bash
  ```
- Requires:
  - curl
  - bash
  - internet connectivity
- Intended for Linux/macOS shell environments.

## Typical use cases

- OCI VM provisioning
- OCI automation scripts
- Resource Manager workflows
- Infrastructure deployment tooling
- Oracle API access from terminal environments
