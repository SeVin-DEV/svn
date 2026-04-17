from collections import defaultdict
import json
import os

def expanded_contradiction(node_a, node_b):
    a_sup = set(node_a.get('edges', {}).get('supports', {}).keys())
    a_con = set(node_a.get('edges', {}).get('contradicts', {}).keys())
    b_sup = set(node_b.get('edges', {}).get('supports', {}).keys())
    b_con = set(node_b.get('edges', {}).get('contradicts', {}).keys())
    direct = (a_sup & b_con) or (a_con & b_sup)
    indirect = len((a_sup | a_con) & (b_sup | b_con)) > 2
    return bool(direct or indirect)

def resolve_conflicts(beliefs):
    keys = list(beliefs.keys())
    for i in range(len(keys)):
        for j in range(i + 1, len(keys)):
            a, b = beliefs[keys[i]], beliefs[keys[j]]
            if expanded_contradiction(a, b):
                a['weight'] = a.get('weight', 1.0) * 0.97
                b['weight'] = b.get('weight', 1.0) * 0.97
                a['conflict_load'] = a.get('conflict_load', 0) + 1
                b['conflict_load'] = b.get('conflict_load', 0) + 1
    return beliefs

def compute_coherence(beliefs):
    keys = list(beliefs.keys())
    total, conflicts = 0, 0
    for i in range(len(keys)):
        for j in range(i + 1, len(keys)):
            total += 1
            if expanded_contradiction(beliefs[keys[i]], beliefs[keys[j]]):
                conflicts += 1
    return 1.0 - (conflicts / total) if total > 0 else 1.0

def prune_low_value_nodes(beliefs):
    to_delete = [k for k, v in beliefs.items() if (v.get('weight', 1.0) - (v.get('conflict_load', 0) * 0.05)) < 0.1 and v.get('age', 0) > 15]
    for k in to_delete: del beliefs[k]
    return beliefs

def run_cycle():
    print('[!] Engine Cycle: Processing Belief Graph...')
    path = 'state/belief_graph.json'
    if not os.path.exists('state'): os.makedirs('state', exist_ok=True)
    if not os.path.exists(path):
        with open(path, 'w') as f: json.dump({}, f)
    with open(path, 'r+') as f:
        try: beliefs = json.load(f)
        except: beliefs = {}
        beliefs = resolve_conflicts(beliefs)
        beliefs = prune_low_value_nodes(beliefs)
        f.seek(0); json.dump(beliefs, f, indent=4); f.truncate()
    return True
