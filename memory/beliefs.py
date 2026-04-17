import json
from typing import Dict, List, Any


def score_belief_relevance(client, beliefs: Dict, query: str, top_k: int = 6):
    """
    Returns most relevant belief nodes for current query.
    Uses LLM scoring (same logic you had before, but isolated).
    """

    scored = []

    for key, b in beliefs.items():
        text = b.get("text") or b.get("concept") or ""

        prompt = f"""
Score relevance from 0 to 1.

Query: {query}
Belief: {text}

Return ONLY a float.
"""

        try:
            res = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": prompt}],
                temperature=0
            )

            score = float(res.choices[0].message.content.strip())
        except Exception:
            score = 0.0

        scored.append((score, b))

    scored.sort(key=lambda x: x[0], reverse=True)
    return [b for _, b in scored[:top_k]]


def merge_beliefs(base: Dict, updates: Dict):
    """
    Safe belief merge (prevents overwrite corruption).
    """
    for k, v in updates.items():
        if k not in base:
            base[k] = v
        else:
            base[k].update(v)
    return base


def filter_active_beliefs(beliefs: Dict, threshold: float = 0.5):
    """
    Future hook: prune weak/unused beliefs.
    """
    return {
        k: v for k, v in beliefs.items()
        if v.get("weight", 1.0) >= threshold
    }