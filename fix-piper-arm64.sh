#!/usr/bin/env bash
# ── SVNTERM Piper ARM64 Patch ───────────────────────────────
# Fixes the "Empty Audio" / "Exec Format Error" on Android/Pixels
set -e

PIPER_DIR="/opt/piper"
PIPER_BINARY="/usr/local/bin/piper"
PIPER_VERSION="2023.11.14-2"

echo "→ Removing incompatible x86_64 Piper..."
rm -rf "$PIPER_DIR"
rm -f "$PIPER_BINARY"

echo "→ Downloading ARM64 (aarch64) Piper binary..."
mkdir -p "$PIPER_DIR"
curl -fsSL "https://github.com/rhasspy/piper/releases/download/${PIPER_VERSION}/piper_linux_aarch64.tar.gz" \
  -o /tmp/piper_arm64.tar.gz

echo "→ Extracting and linking..."
tar -xzf /tmp/piper_arm64.tar.gz -C "$PIPER_DIR" --strip-components=1
ln -sf "${PIPER_DIR}/piper" "$PIPER_BINARY"
chmod +x "$PIPER_BINARY"

# Verify the binary is executable on this architecture
echo "→ Verifying binary..."
if piper --version &> /dev/null; then
    echo "✓ Piper is now functional on ARM64."
else
    echo "× Warning: Piper verification failed. You may need to check proot shared libraries."
fi

rm -f /tmp/piper_arm64.tar.gz