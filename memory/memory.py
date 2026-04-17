import json
from pathlib import Path
from datetime import datetime

MEMORY_FILE = Path("data/memory.json")


def load_memory():
    if MEMORY_FILE.exists():
        try:
            return json.loads(MEMORY_FILE.read_text())
        except Exception:
            return _default()
    return _default()


def save_memory(memory: dict):
    MEMORY_FILE.parent.mkdir(parents=True, exist_ok=True)
    MEMORY_FILE.write_text(json.dumps(memory, indent=2))


def _default():
    return {
        "summary": "",
        "last_updated": "",
        "events": [],
        "flags": {}
    }


def append_event(memory: dict, event: dict):
    memory.setdefault("events", [])
    event["timestamp"] = datetime.utcnow().isoformat()
    memory["events"].append(event)
    return memory