from datetime import datetime


def summarize_history(client, history: list) -> str | None:
    """
    Condenses recent conversation into persistent memory summary.
    """

    if len(history) < 6:
        return None

    convo = "\n".join(
        [f"{m.get('role')}: {m.get('content')}" for m in history[-12:]]
    )

    prompt = f"""
Summarize this conversation into persistent memory.

Focus on:
- stable user preferences
- ongoing projects
- identity-relevant facts
- unresolved threads

Be concise and information-dense.

{convo}
"""

    try:
        res = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3
        )

        return res.choices[0].message.content.strip()

    except Exception:
        return None


def stamp_summary(memory: dict, summary: str):
    memory["summary"] = summary
    memory["last_updated"] = datetime.utcnow().isoformat()
    return memory