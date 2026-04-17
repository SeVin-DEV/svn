import json
import os

class MemoryRuntimeLayer:
    def __init__(self):
        self.state_path = "state/memory_state.json"
        self.belief_path = "state/belief_graph.json"
        self.data = self._load_initial_state()

    def _load_initial_state(self):
        # Ensuring the state directory exists
        os.makedirs("state", exist_ok=True)
        
        if os.path.exists(self.state_path):
            with open(self.state_path, 'r') as f:
                return json.load(f)
        return {"status": "initialized", "observations": []}

    def update_state(self, new_data):
        self.data.update(new_data)
        with open(self.state_path, 'w') as f:
            json.dump(self.data, f, indent=4)
        print(f"[!] Memory State Updated.")

    def get_context(self):
        return self.data
