import json
from core.persistence import load_json, save_json
from core.engine import resolve_conflicts, prune_low_value_nodes, compute_coherence

def run_sovereign_maintenance(client, model, user_input, ai_response):
    state = load_json("memory_state.json", {"identity_stability": 0.9})
    beliefs = load_json("memory_belief_graph.json", {})

    prompt = (
        f"MAINTENANCE: U: {user_input} | A: {ai_response}\n"
        "Return JSON with: concept, weight, supports (list), contradicts (list)."
    )

    try:
        res = client.chat.completions.create(
            model=model,
            messages=[{"role": "system", "content": prompt}],
            response_format={"type": "json_object"}
        )

        update = json.loads(res.choices[0].message.content)
        c_name = update.get("concept", "GENERAL").upper()

        if c_name not in beliefs:
            beliefs[c_name] = {
                "concept": c_name,
                "weight": update.get("weight", 0.5),
                "age": 1,
                "edges": {"supports": {}, "contradicts": {}},
                "conflict_load": 0
            }

        # Update weight and resolve graph conflicts
        beliefs[c_name]["weight"] = (beliefs[c_name]["weight"] * 0.7) + (update.get("weight", 0.5) * 0.3)
        beliefs[c_name]["age"] += 1

        beliefs = resolve_conflicts(beliefs)
        beliefs = prune_low_value_nodes(beliefs)
        coherence = compute_coherence(beliefs)

        # Identity Stability calculation
        state["identity_stability"] = (state["identity_stability"] * 0.9) + (coherence * 0.1)

        save_json("memory_state.json", state)
        save_json("memory_belief_graph.json", beliefs)
        print(f"[MAINTENANCE] Coherence updated: {coherence:.4f}")

    except Exception as e:
        print(f"[ERROR] Maintenance Kernel failure: {e}")

def patch(app):
    app.run_maintenance = run_sovereign_maintenance
    print("[PATCH] Sovereign Maintenance logic engaged.")
