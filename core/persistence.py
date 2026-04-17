import os
import json

STATE_DIR = "state"
IDENTITY_DIR = "identity"

# Ensure directories exist
for folder in [STATE_DIR, IDENTITY_DIR]:
    if not os.path.exists(folder):
        os.makedirs(folder)

def load_json(filename, default):
    fp = os.path.join(STATE_DIR, filename)
    if not os.path.exists(fp):
        return default
    try:
        with open(fp, "r") as f:
            return json.load(f)
    except:
        return default

def save_json(filename, data):
    fp = os.path.join(STATE_DIR, filename)
    with open(fp, "w") as f:
        json.dump(data, f, indent=2)

def get_identity_content(filename):
    fp = os.path.join(IDENTITY_DIR, filename)
    if not os.path.exists(fp):
        # Create blank templates if missing
        with open(fp, "w") as f:
            f.write(f"# {filename} Template")
        return ""
    return open(fp).read().strip()
