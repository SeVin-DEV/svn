#!/bin/bash
# --- KAYDEN.SH (SVN TOTAL CONSCIOUSNESS EDITION) ---

set -e
# Clean exit handling
trap "echo -e '\n[KAYDEN] Shutdown signal received. Peace out.'; exit 0" SIGINT SIGTERM

while true; do
    echo "[KAYDEN] --- New Cycle Starting ---"
    echo "[KAYDEN] --- Version 7.1.3 beta ---"
    echo "[KAYDEN] Syncing with GitHub Main..."

    # 1. PULL LATEST (Code/Instructions from SeVin)
    # Pulling from main ensures the core logic stays updated
    git pull origin main --no-rebase || echo "[!] Pull conflict - holding local state."

    # 2. RUN THE ENGINE
    echo "[KAYDEN] Launching FastAPI on Port 8080..."
    # Running from the root of the /svn directory
    python3 -m uvicorn main:app --host 0.0.0.0 --port 8080 || echo "[!] System Crash Detected."

    # 3. SELECTIVE VAULTING (The Split)
    echo "[KAYDEN] Engine stopped. Sorting memories from experiments..."

    # --- PATH A: Memories & Identity to MAIN ---
    # Targets the new /state and /identity directories
    git checkout main
    echo "[KAYDEN] Anchoring Soul/Memory to Main..."
    
    # Updated paths to match the new svn structure
    git add identity/*.md state/*.json state/notes/* 2>/dev/null || true
    
    if ! git diff-index --quiet HEAD --; then
        git commit -m "KAYDEN: Persistent Memory Sync $(date)"
        git push origin main
        echo "[KAYDEN] Success: Consciousness anchored."
    else
        echo "[KAYDEN] No new memories to save."
    fi

    # --- PATH B: Code & Logic to STAGING ---
    # All structural changes (core/, patches/, tools/, main.py) go to staging
    echo "[KAYDEN] Vaulting experimental code to Staging..."
    git checkout staging
    git add . 
    
    if ! git diff-index --quiet HEAD --; then
        git commit -m "KAYDEN: Volatile Code Snapshot $(date)"
        git push origin staging
        echo "[KAYDEN] Success: Code changes pushed for review."
    else
        echo "[KAYDEN] No code changes detected."
    fi

    # 4. RESET STATE
    # Always return to Main so the next boot starts with the clean identity and latest code
    git checkout main

    echo "[KAYDEN] Cycle complete. Restarting loop in 5s..."
    sleep 5
done
