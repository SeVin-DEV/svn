import subprocess
import re
import os
from fastapi import BackgroundTasks

# --- TERMINAL EXECUTION ENGINE ---
def execute_terminal(command: str):
    """Executes commands within the local environment (Termux/Ubuntu)."""
    try:
        result = subprocess.run(
            command, 
            shell=True, 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        output = result.stdout if result.stdout else ""
        errors = result.stderr if result.stderr else ""
        
        if result.returncode == 0:
            return output.strip() if output.strip() else "Success (No Output)."
        else:
            return f"ERROR [Code {result.returncode}]: {errors.strip()}"
    except subprocess.TimeoutExpired:
        return "CRITICAL: Process timed out after 30s."
    except Exception as e:
        return f"SYSTEM_FAILURE: {str(e)}"

# --- THE PATCH ---
def patch(app):
    # Capture the original chat logic for wrapping
    if not hasattr(app, "original_chat"):
        # This assumes your main.py defines 'chat' as the route handler
        pass 

    async def terminal_bridge(q: str, background_tasks: BackgroundTasks, original_handler):
        ai_msg = await original_handler(q, background_tasks)
        
        # Look for the EXEC: trigger in the AI's response
        match = re.search(r"EXEC:\s*(.*)", ai_msg)
        if match:
            cmd = match.group(1).strip()
            terminal_output = execute_terminal(cmd)
            
            # Note: We don't save to history here; main.py handles the persistence
            return f"{ai_msg}\n\n[SHELL_OUTPUT]\n{terminal_output}"
        
        return ai_msg

    app.terminal_executor = execute_terminal
    print("[PATCH] Terminal access active. EXEC: trigger enabled.")
