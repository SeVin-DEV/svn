import os
 import importlib.util
 
 ACTIVE_TOOLS = {}
 
 def initialize_bus(app, manifest):
     """Pre-loads the tool logic so it's ready for hot-swappable calls."""
     global ACTIVE_TOOLS
     tool_names = manifest.split(",") if manifest else []
     
     for name in tool_names:
         path = f"tools/{name}.py"
         if os.path.exists(path):
             ACTIVE_TOOLS[name] = path
 
     if not hasattr(app, "extra_instructions"):
         app.extra_instructions = []
     app.extra_instructions.append(f"TOOL_BUS_ACTIVE: Functional tools available: [{manifest}]")
 
 def call(tool_name, **kwargs):
     """The Middleman: Dynamically imports and runs a specific tool."""
     if tool_name in ACTIVE_TOOLS:
         # PnP Logic: Import the specific tool file on demand
         spec = importlib.util.spec_from_file_location(tool_name, ACTIVE_TOOLS[tool_name])
         module = importlib.util.module_from_spec(spec)
         spec.loader.exec_module(module)
         
         if hasattr(module, "run"):
             return module.run(**kwargs)
     return f"ERROR: Tool '{tool_name}' not found or has no 'run' function."
 
