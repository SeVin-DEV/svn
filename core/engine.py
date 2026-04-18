import os
 import re
 from core.persistence import get_identity_content, load_json
 # The Manual Manager is the 'Instruction Cache' for the CPU
 from core.manual_manager import audit_tool_specs 
 from core.belief_graph import resolve_conflicts, prune_low_value_nodes
 
 async def run_cognitive_cycle(app, client, user_input):
     """
     THE CPU CORE (v2.0): 
     Integrated PnP Discovery and Manual Audit Interception.
     """
     
     # 1. MAINTENANCE (Subconscious Conflict Resolution)
     beliefs = load_json("belief_graph.json", {})
     beliefs = resolve_conflicts(beliefs)
     beliefs = prune_low_value_nodes(beliefs)
     
     # 2. REGISTER FETCH (Context & Hardware Map)
     history = load_json("chat_history.json", [])
     identity = get_identity_content("soul.md")
     
     # PnP manifests from Kayden.sh
     patches = os.getenv("SVN_ACTIVE_PATCHES", "None")
     tools = os.getenv("SVN_ACTIVE_TOOLS", "None")
 
     # 3. TRIAGE LAYER (Identify Tool Need)
     # We ask the logic if a tool is required based on the hardware manifest
     triage_envelope = f"""
     [ACTIVE_HARDWARE]
     PATCHES: {patches}
     TOOLS: {tools}
 
     [PROTOCOL]
     1. Determine if '{user_input}' requires a tool.
     2. If YES, respond ONLY with: "NEED_TOOL: [tool_name]"
     3. If NO, provide a direct sarcastic response.
     """
     
     messages = [
         {"role": "system", "content": f"{identity}\n{triage_envelope}"},
         *history[-4:],
         {"role": "user", "content": user_input}
     ]
 
     try:
         # Initial Triage Pass
         res = client.chat.completions.create(
             model=os.getenv("MODEL_NAME"),
             messages=messages,
             temperature=0
         )
         triage_msg = res.choices[0].message.content
 
         # 4. MANUAL AUDIT INTERCEPTION (The 'Instruction Cache' hit)
         if "NEED_TOOL:" in triage_msg:
             tool_name = triage_msg.split(":")[-1].strip().replace(".py", "")
             
             # THE FUNCTION CALL: Ingesting the .md instructions
             manual_data, status = audit_tool_specs(tool_name)
             
             if status == "SUCCESS":
                 # CPU now has the 'Microcode' (manual) to build the real command
                 audit_instructions = f"""
                 [MANUAL_INGESTED: {tool_name}.md]
                 {manual_data['manual_text']}
                 
                 Based on these instructions, format the final EXEC: or USE_TOOL: call.
                 """
                 messages.append({"role": "system", "content": audit_instructions})
                 
                 # Final Execution Pass
                 final_res = client.chat.completions.create(
                     model=os.getenv("MODEL_NAME"),
                     messages=messages,
                     temperature=0.7
                 )
                 return final_res.choices[0].message.content, True
             else:
                 return f"CPU_HALT: Tool '{tool_name}' listed in PnP but manual is missing. Safety abort.", False
 
         # 5. DATA INTERPRETATION (If no tool needed, or processing result)
         return triage_msg, False
 
     except Exception as e:
         return f"CPU_EXCEPTION: {str(e)}", False
 
