import core.engine as engine
from core.buffer import triage_input

original_run_cycle = engine.run_cycle

def patched_run_cycle():
    print('[!] Patch: Intercepting Engine Cycle...')
    if triage_input('current_interaction'):
        return original_run_cycle()
    print('[!] Patch: Concept below threshold. Skipping heavy math.')
    return True

engine.run_cycle = patched_run_cycle
print('[SYSTEM] Patch integrated: buffer_gate.py (Engine intercept active)')