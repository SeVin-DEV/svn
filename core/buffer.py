import json
import os

BUFFER_PATH = 'state/buffer_zone.json'
THRESHOLD = 3

def triage_input(obs_id):
    if not os.path.exists('state'): os.makedirs('state', exist_ok=True)
    if not os.path.exists(BUFFER_PATH):
        with open(BUFFER_PATH, 'w') as f: json.dump({}, f)
    with open(BUFFER_PATH, 'r+') as f:
        try: data = json.load(f)
        except: data = {}
        data[obs_id] = data.get(obs_id, 0) + 1
        promote = data[obs_id] >= THRESHOLD
        if promote: data[obs_id] = 0
        f.seek(0); json.dump(data, f, indent=4); f.truncate()
        return promote