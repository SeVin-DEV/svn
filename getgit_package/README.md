# getgit.sh

GitHub SSH key and Git configuration helper.

This script configures global Git identity settings, creates an Ed25519 SSH key if one does not already exist, starts `ssh-agent`, adds the key, adds GitHub to `known_hosts`, and prints the public key so it can be added to a GitHub repository as a deploy key.

## Files

- `getgit.sh` — Git and GitHub SSH setup automation script.

## Requirements

The target machine should have:

- Bash
- Git
- OpenSSH client tools:
  - `ssh-keygen`
  - `ssh-agent`
  - `ssh-add`
  - `ssh-keyscan`

## Usage

From the folder containing the script:

```bash
chmod +x getgit.sh
./getgit.sh
```

The script will ask for:

1. Git user name
2. Git email address

It will then configure:

```bash
git config --global user.name
git config --global user.email
git config --global init.defaultBranch main
```

## GitHub deploy key step

After the script prints the public key, copy it exactly and add it here:

```text
GitHub -> Repository -> Settings -> Deploy keys -> Add deploy key
```

Suggested key name:

```text
Alibaba svnterm Backend
```

Then test the SSH connection:

```bash
ssh -T git@github.com
```

## Notes

- The script uses `~/.ssh/id_ed25519`.
- If that key already exists, the script does not overwrite it.
- The script appends GitHub's Ed25519 host key to `~/.ssh/known_hosts`, then removes duplicate entries.
- This script is intended for machines/servers that need SSH access to GitHub repositories.
