# core/state.py

import json
from pathlib import Path


class StateManager:
    """
    Handles session-level state:
    - chat history
    - beliefs (working set)
    - runtime variables
    """

    def __init__(self, path="data/state.json"):
        self.path = Path(path)

    # -----------------------------

    def load_state(self):
        if self.path.exists():
            return json.loads(self.path.read_text())

        return {
            "history": [],
            "beliefs": {},
            "system_context": "",
            "runtime_flags": {}
        }

    # -----------------------------

    def save_state(self, state: dict):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(json.dumps(state, indent=2))