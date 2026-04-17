# core/engine.py

import json
from datetime import datetime


class CognitiveEngine:
    def __init__(self, app):
        self.app = app

    async def run_cycle(self, user_input: str):
        """
        Full cognition cycle:
        - load state
        - memory update
        - belief filtering
        - context construction
        - model execution
        """

        state = self.app.state.load_state()
        history = state.get("history", [])
        beliefs = state.get("beliefs", {})

        # --- STEP 1: Append user input ---
        history.append({"role": "user", "content": user_input})

        # --- STEP 2: MEMORY SUMMARIZATION ---
        memory_summary = self.app.memory.summarize_if_needed(history)

        if memory_summary:
            self.app.memory.save_summary({
                "summary": memory_summary,
                "last_updated": datetime.utcnow().isoformat()
            })

        # --- STEP 3: LOAD LONG-TERM MEMORY ---
        memory_data = self.app.memory.load_summary()

        # --- STEP 4: BELIEF RELEVANCE FILTER ---
        relevant_beliefs = self.app.memory.score_beliefs(
            beliefs,
            user_input
        )

        # --- STEP 5: BUILD SYSTEM CONTEXT ---
        system_context = self.build_system_context(
            memory_data,
            relevant_beliefs
        )

        # Inject into state (important for downstream use)
        state["system_context"] = system_context

        # --- STEP 6: MODEL CALL ---
        response = await self.call_model(
            system_context,
            history
        )

        # --- STEP 7: APPEND RESPONSE ---
        history.append({"role": "assistant", "content": response})

        # --- STEP 8: SAVE STATE ---
        state["history"] = history
        self.app.state.save_state(state)

        return response

    # -----------------------------

    def build_system_context(self, memory_data, beliefs):
        """
        Construct system prompt context
        """
        memory_text = memory_data.get("summary", "")

        return f"""
LONG TERM MEMORY:
{memory_text}

RELEVANT BELIEFS:
{json.dumps(beliefs, indent=2)}
"""

    # -----------------------------

    async def call_model(self, system_context, history):
        """
        Handles model execution
        """

        messages = [
            {"role": "system", "content": system_context}
        ] + history

        try:
            response = await self.app.client.chat.completions.create(
                model=self.app.config.model_name,
                messages=messages,
                temperature=0.7
            )

            return response.choices[0].message.content.strip()

        except Exception as e:
            return f"[MODEL ERROR] {str(e)}"