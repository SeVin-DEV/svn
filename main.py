import os
import importlib.util
import sys
from fastapi import FastAPI, BackgroundTasks, Request
from fastapi.responses import HTMLResponse
from openai import OpenAI
from dotenv import load_dotenv

# Internal Imports from your new Core layer
from core.persistence import load_json, save_json, get_identity_content
from core.user_model import MemoryRuntimeLayer # If you moved the runtime model here

load_dotenv()

# --- CONFIG ---
NIM_KEY = os.getenv("NVIDIA_API_KEY")
NIM_BASE_URL = os.getenv("URL")
MODEL_NAME = os.getenv("MODEL_NAME", "moonshotai/kimi-k2-instruct")

client = OpenAI(base_url=NIM_BASE_URL, api_key=NIM_KEY)
app = FastAPI()
app.state.user_model = MemoryRuntimeLayer() # Initializing your behavioral tracker

# --- MODULAR PATCH LOADER ---
def apply_patches(app_instance):
    patch_dir = "patches"
    if not os.path.exists(patch_dir):
        return
    
    patch_files = sorted([f for f in os.listdir(patch_dir) if f.endswith(".py")])
    for plugin in patch_files:
        path = os.path.join(patch_dir, plugin)
        module_name = f"patches.{plugin[:-3]}"
        spec = importlib.util.spec_from_file_location(module_name, path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        if hasattr(module, "patch"):
            module.patch(app_instance)
            print(f"[SYSTEM] Patch integrated: {plugin}")

# --- API ROUTES ---
@app.get("/", response_class=HTMLResponse)
async def index():
    # This remains your green-on-black terminal UI
    return get_identity_content("ui_template.html") # Or keep the string from old main

@app.get("/chat")
async def chat(q: str, background_tasks: BackgroundTasks):
    state = load_json("memory_state.json", {"identity_stability": 0.9})
    history = load_json("chat_history.json", [])
    
    # Constructing the Sovereign Prompt
    stability = state.get("identity_stability", 0.9)
    mode = "cautious" if stability < 0.7 else "assertive"
    
    # Injecting instructions from patches (like the Audit Guard)
    extra_rules = "\n".join(getattr(app, "extra_instructions", []))
    
    master_system = f"""
    IDENTITY: {get_identity_content("soul.md")}
    DIRECTIVE: {get_identity_content("system.md")}
    USER_PROFILE: {get_identity_content("user_profile.md")}
    
    STATUS: Mode={mode} | Stability={stability}
    {extra_rules}
    """

    messages = [{"role": "system", "content": master_system}] + history[-8:] + [{"role": "user", "content": q}]

    try:
        res = client.chat.completions.create(
            model=MODEL_NAME,
            messages=messages
        )
        ai_msg = res.choices[0].message.content

        # Update History
        history.append({"role": "user", "content": q})
        history.append({"role": "assistant", "content": ai_msg})
        save_json("chat_history.json", history[-10:])

        # Trigger background maintenance patch
        if hasattr(app, "run_maintenance"):
            background_tasks.add_task(app.run_maintenance, client, MODEL_NAME, q, ai_msg)

        # Apply terminal bridge if the patch is loaded
        if "EXEC:" in ai_msg and hasattr(app, "terminal_executor"):
            # The terminal patch handles the execution and output appending
            pass 

        return ai_msg

    except Exception as e:
        return f"KERNEL_PANIC: {str(e)}"

# --- BOOTSTRAP ---
apply_patches(app)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
