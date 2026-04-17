def patch(app):
    audit_instruction = """
    CRITICAL PROTOCOL: MANUAL_AUDIT
    1. Every tool in /tools/ has a corresponding .md manual.
    2. Before running any 'EXEC:' command, you must verify usage via the .md file.
    3. Run 'EXEC: ls tools/*.md' if you need to see available manuals.
    """
    
    # Store this in the app state so main.py can inject it into the prompt
    if not hasattr(app, "extra_instructions"):
        app.extra_instructions = []
    app.extra_instructions.append(audit_instruction)
    
    print("[PATCH] Manual Audit protocol active. KAYDEN is now self-documenting.")
