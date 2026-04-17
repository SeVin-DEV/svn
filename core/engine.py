from collections import defaultdict

def expanded_contradiction(node_a, node_b):
    """
    Enhanced contradiction model from Cognitive v5.
    Detects direct edge conflicts and indirect neighborhood overlap.
    """
    a_sup = set(node_a.get("edges", {}).get("supports", {}).keys())
    a_con = set(node_a.get("edges", {}).get("contradicts", {}).keys())
    b_sup = set(node_b.get("edges", {}).get("supports", {}).keys())
    b_con = set(node_b.get("edges", {}).get("contradicts", {}).keys())

    # Direct conflict: One supports what the other contradicts
    direct = (a_sup & b_con) or (a_con & b_sup)
    
    # Indirect: High overlap of shared neighbors regardless of polarity
    indirect = len((a_sup | a_con) & (b_sup | b_con)) > 2
    
    return bool(direct or indirect)

def resolve_conflicts(beliefs):
    keys = list(beliefs.keys())
    for i in range(len(keys)):
        for j in range(i + 1, len(keys)):
            a, b = beliefs[keys[i]], beliefs[keys[j]]
            if expanded_contradiction(a, b):
                # Apply the weight decay (Identity Stability logic)
                a["weight"] *= 0.97
                b["weight"] *= 0.97
                a.setdefault("conflict_load", 0)
                b.setdefault("conflict_load", 0)
                a["conflict_load"] += 1
                b["conflict_load"] += 1
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
    # Prune nodes that are old, low weight, and high conflict
    to_delete = [
        k for k, v in beliefs.items()
        if (v.get("weight", 0) - (v.get("conflict_load", 0) * 0.05)) < 0.1
        and v.get("age", 0) > 15
    ]
    for k in to_delete:
        del beliefs[k]
    return beliefs
