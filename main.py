import os
 import importlib.util
 import re
 import uvicorn
 from fastapi import FastAPI, BackgroundTasks, Request
 from fastapi.responses import HTMLResponse
 from openai import OpenAI
 from dotenv import load_dotenv
 
 # Core Persistence & Reasoning Layer
 from core.persistence import load_json, save_json, get_identity_content
 from core.engine import run_cognitive_cycle 
 
 load_dotenv()
 
 # --- INITIALIZE THE SWITCHBOARD ---
 app = FastAPI()
 client = OpenAI(
     base_url=os.getenv("URL"), 
     api_key=os.getenv("NVIDIA_API_KEY")
 )
 
 def mount_pnp_buses(app_instance):
     """
     POWER-ON SELF-TEST (POST)
     Hooks the Bridge Controllers for Patches and Tools.
     """
     for bus in ["patches", "tools"]:
         bridge_path = f"{bus}/{bus}_bridge.py"
         
         if os.path.exists(bridge_path):
             # Dynamically load the Bridge (The Middleman)
             spec = importlib.util.spec_from_file_location(f"{bus}_bus", bridge_path)
             module = importlib.util.module_from_spec(spec)
             spec.loader.exec_module(module)
             
             # Plug the bridge into the switchboard receptacle
             setattr(app_instance, f"{bus}_bus", module)
             
             # Hand over the PnP manifest from Kayden.sh environment
             manifest = os.getenv(f"SVN_ACTIVE_{bus.upper()}", "")
             if hasattr(module, "initialize_bus"):
                 module.initialize_bus(app_instance, manifest)
             
             print(f"[KERNEL] {bus.upper().rstrip('ES')} BUS MOUNTED: {manifest}")
         else:
             print(f"[WARNING] {bus.upper()} Bridge missing from backplane.")
 
 # --- THE SIGNAL FLOW (API ROUTES) ---
 
 @app.get("/", response_class=HTMLResponse)
 async def index():
     # Renders the UI template from your identity folder
     return get_identity_content("ui_template.html")
 
 @app.get("/chat")
 async def chat(q: str, background_tasks: BackgroundTasks):
     """
     The main routing loop. Directs input to the engine and 
     filters output back to the peripheral bridges.
     """
     # 1. ROUTE TO COGNITIVE CORE
     # The 'Thinking' happens in core/engine.py
     ai_msg, action_required = await run_cognitive_cycle(app, client, q)
 
     # 2. INTERCEPT & ROUTE TO PERIPHERALS
     # If the engine issues a command, the switchboard plugs the signal into a bridge.
     
     # --- Path A: Patch Bus (EXEC: Terminal/System) ---
     if "EXEC:" in ai_msg and hasattr(app, "patches_bus"):
         match = re.search(r"EXEC:\s*(.*)", ai_msg)
         if match:
             cmd = match.group(1).strip()
             # Directing signal to patches/patches_bridge.py
             shell_result = app.patches_bus.call(cmd)
             ai_msg = f"{ai_msg}\n\n[SHELL_OUTPUT]\n{shell_result}"
 
     # --- Path B: Tool Bus (USE_TOOL: Modular Logic) ---
     elif "USE_TOOL:" in ai_msg and hasattr(app, "tools_bus"):
         match = re.search(r"USE_TOOL:\s*(\w+)", ai_msg)
         if match:
             tool_name = match.group(1).strip()
             # Directing signal to tools/tools_bridge.py
             tool_result = app.tools_bus.call(tool_name)
             ai_msg = f"{ai_msg}\n\n[TOOL_RESULT]\n{tool_result}"
 
     # 3. CONSOLIDATE & RECORD
     history = load_json("chat_history.json", [])
     history.append({"role": "user", "content": q})
     history.append({"role": "assistant", "content": ai_msg})
     save_json("chat_history.json", history[-10:])
 
     # Background maintenance task (Belief weighting, etc.)
     if hasattr(app, "run_maintenance"):
         background_tasks.add_task(app.run_maintenance, client, os.getenv("MODEL_NAME"), q, ai_msg)
 
     return ai_msg
 
 # --- BOOTSTRAP ---
 mount_pnp_buses(app)
 
 if __name__ == "__main__":
     # Binds to Port 8080 as required by the Kayden.sh hypervisor
     uvicorn.run(app, host="0.0.0.0", port=8080)
 
