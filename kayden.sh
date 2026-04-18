#!/bin/bash
 # --- KAYDEN.SH (SVN TOTAL CONSCIOUSNESS EDITION + PnP SCANNER) ---
 
 set -e
 trap "echo -e '\n[KAYDEN] Shutdown signal received. Peace out.'; exit 0" 2 15
 
 while true; do
     echo "[KAYDEN] --- New Cycle Starting ---"
     echo "[KAYDEN] --- Version 7.1.4 (PnP Active) ---"
 
     # --- NEW FUNCTION: PnP SCANNER ---
     echo "[KAYDEN] Scanning Peripheral Buses..."
     
     # Index files, stripping paths and extensions for the manifest
     PATCH_LIST=$(ls patches/*.py 2>/dev/null | grep -v "patches_bridge.py" | xargs -n 1 basename | sed 's/\.py//' | tr '\n' ',' | sed 's/,$//')
     TOOL_LIST=$(ls tools/*.py 2>/dev/null | grep -v "tools_bridge.py" | xargs -n 1 basename | sed 's/\.py//' | tr '\n' ',' | sed 's/,$//')
 
     # Verify Bus Controllers (Middlemen)
     if [ ! -f "patches/patches_bridge.py" ] || [ ! -f "tools/tools_bridge.py" ]; then
         echo "[CRITICAL] Bus Controllers Missing! Ensure bridge files exist."
         exit 1
     fi
 
     # Export manifests to the Kernel environment
     export SVN_ACTIVE_PATCHES=$PATCH_LIST
     export SVN_ACTIVE_TOOLS=$TOOL_LIST
     echo "[KAYDEN] Hardware Initialized: [${PATCH_LIST:-None}] | [${TOOL_LIST:-None}]"
 
     # --- LEGACY FUNCTION: SYNC ---
     echo "[KAYDEN] Syncing with GitHub Main..."
     git pull origin main --no-rebase || echo "[!] Pull conflict - holding local state."
 
     # --- CORE FUNCTION: LAUNCH KERNEL ---
     echo "[KAYDEN] Launching FastAPI Kernel on Port 8080..."
     python3 main.py || echo "[!] System Crash Detected."
 
     # --- LEGACY FUNCTION: SELECTIVE VAULTING ---
     echo "[KAYDEN] Engine stopped. Sorting memories from experiments..."
 
     # Path A: Soul/Memory to Main
     git checkout main
     echo "[KAYDEN] Anchoring Soul/Memory to Main..."
     git add identity/*.md state/*.json state/notes/* 2>/dev/null || true
     
     if ! git diff-index --quiet HEAD --; then
         git commit -m "KAYDEN: Persistent Memory Sync $(date)"
         git push origin main
         echo "[KAYDEN] Success: Consciousness anchored."
     fi
 
     # Path B: Code & Logic to Staging
     echo "[KAYDEN] Vaulting experimental code to Staging..."
     git checkout staging
     git add . 
     if ! git diff-index --quiet HEAD --; then
         git commit -m "KAYDEN: Volatile Code Snapshot $(date)"
         git push origin staging
         echo "[KAYDEN] Success: Code changes pushed for review."
     fi
 
     # Reset to Main for next boot
     git checkout main
 
     echo "[KAYDEN] Cycle complete. Restarting in 5s..."
     sleep 5
 done
 
