# envmaker.sh

Automated shell script `.env` conversion utility.

EnvMaker scans interactive shell scripts for `read` prompts, generates a matching `.env` file, injects automatic environment loading logic, and converts prompts into conditional prompts for automation-friendly execution.

## Files

- `envmaker.sh` — interactive script automation helper

## Usage

Make executable:

```bash
chmod +x envmaker.sh
```

Run:

```bash
./envmaker.sh your_script.sh
```

Example:

```bash
./envmaker.sh svnterm.sh
```

## What the script does

### 1. Scans for interactive prompts

Searches for lines matching shell `read` prompts such as:

```bash
read -rp "Prompt" VARIABLE
```

Extracts detected variable names automatically.

## Detected variables

For example:

```bash
read -rp "API Key: " API_KEY
```

creates:

```text
API_KEY=""
```

inside `.env`.

## .env injection

If the target script does not already load a `.env` file, EnvMaker injects:

```bash
if [ -f "$(dirname "$0")/.env" ]; then
  source "$(dirname "$0")/.env"
fi
```

directly after the shebang.

## Conditional prompt conversion

Converts prompts from:

```bash
read -rp "Prompt" VARIABLE
```

to:

```bash
[ -z "$VARIABLE" ] && read -rp "Prompt" VARIABLE
```

This allows:

- fully automated runs
- optional interactive fallback
- CI/CD compatibility
- pre-filled environment execution

## Generated files

Creates or updates:

```text
.env
```

inside the same directory as the target script.

## Example workflow

### Original script

```bash
read -rp "Enter API Key: " API_KEY
```

### After EnvMaker

```bash
[ -z "$API_KEY" ] && read -rp "Enter API Key: " API_KEY
```

### Generated .env

```text
API_KEY=""
```

## Typical use cases

- deployment automation
- CI/CD conversion
- cloud provisioning scripts
- infrastructure automation
- self-host install scripts
- secret externalization

## Notes

- The outer heredoc wrapper was removed from the packaged version.
- The downloadable file starts directly with:
  ```bash
  #!/usr/bin/env bash
  ```
- Requires:
  - bash
  - grep
  - awk
  - sed
- Designed for Linux/macOS shell environments.
- Existing `.env` entries are preserved if already present.
