#!/usr/bin/env bash
# ── SVNTERM Termux Automation — Final Stage ───────────────────
# Use this to repair the shell path and prepare for the build.
set -e

echo "→ Configuring shell environment for pnpm..."
# 1. Export variables for the current session
export SHELL=/bin/bash
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# 2. Persist variables for future logins
{
  echo "export SHELL=/bin/bash"
    echo "export PNPM_HOME=\"$HOME/.local/share/pnpm\""
      echo "export PATH=\"\$PNPM_HOME:\$PATH\""
      } >> ~/.bashrc

      # 3. Force-link pnpm to a standard binary path
      if [ -f "$HOME/.local/share/pnpm/pnpm" ]; then
          echo "→ Linking pnpm to /usr/local/bin..."
              ln -sf "$HOME/.local/share/pnpm/pnpm" /usr/local/bin/pnpm
              fi

              # 4. Verify pnpm and initialize Node.js LTS
              if command -v pnpm &> /dev/null; then
                  echo "→ pnpm found. Setting up Node environment..."
                      pnpm setup
                          pnpm env use --global lts
                          else
                              echo "× Error: pnpm is still not in the PATH. Check install logs."
                                  exit 1
                                  fi

                                  # 5. Ensure the database is active before moving forward
                                  echo "→ Checking PostgreSQL service..."
                                  service postgresql start || pg_ctlcluster 14 main start

                                  echo ""
                                  echo "✓ Environment ready. You can now run your main install script."