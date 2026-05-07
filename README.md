# auto.sh

Auto-deploy orchestration script with integrated EnvMaker behavior.

This script accepts either a local directory or a GitHub repository URL, scans `.sh` scripts for interactive prompts, generates or updates a `.env` file, makes prompts conditional, then runs the detected scripts in alphabetical order.

## Files

- `auto.sh` — auto-deploy orchestrator

## Usage

```bash
chmod +x auto.sh
./auto.sh
```

## What it does

- Clones or updates a Git repository, or uses a local directory.
- Scans `.sh` files for interactive `read` prompts.
- Creates or updates `.env`.
- Injects `.env` loading logic into target scripts.
- Converts prompts to conditional prompts.
- Runs all `.sh` scripts in alphabetical order.

## Important note

The script references `${BLUE}` during execution, but `BLUE` is not currently defined in the pasted script. This is cosmetic because `set -u` is not enabled.

To fix the color output, add this near the other color definitions:

```bash
BLUE='\033[0;34m'
```

## Notes

- The outer heredoc wrapper was removed.
- The downloadable file starts directly with `#!/usr/bin/env bash`.
- This script modifies target `.sh` files in place.
