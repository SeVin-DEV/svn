import os
 import subprocess
 
 def initialize_bus(app, manifest):
     """Registers the 'EXEC:' capability with the agent's prompt."""
     if not hasattr(app, "extra_instructions"):
         app.extra_instructions = []
     
     # Inject the list of usable patches provided by the Bootloader
     app.extra_instructions.append(f"PATCH_BUS_ACTIVE: Terminal Access via modules: [{manifest}]")
 
 def call(command):
     """The Middleman: Translates Kernel request into Shell execution."""
     try:
         # Standard execution bridge for patches
         result = subprocess.check_output(command, shell=True, text=True, stderr=subprocess.STDOUT)
         return result if result else "Success (No Output)."
     except Exception as e:
         return f"EXEC_ERROR: {str(e)}"
 
