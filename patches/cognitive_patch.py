from datetime import datetime
from memory.summarizer import summarize_history, stamp_summary
from memory.beliefs import score_belief_relevance
from memory.memory import load_memory, save_memory


def apply(app):

    original_engine = app.engine.run_cycle

    async def patched_cycle(input_text: str, toolbox=None, **kwargs):

        state = app.state_manager.load_state()

        history = state.get("history", [])
        beliefs = state.get("beliefs", {})

        memory = load_memory()

        # ----------------------------
        # MEMORY SUMMARIZATION STEP
        # ----------------------------
        summary = summarize_history(app.client, history)
        if summary:
            memory = stamp_summary(memory, summary)
            save_memory(memory)

        # ----------------------------
        # BELIEF FILTERING STEP
        # ----------------------------
        relevant_beliefs = score_belief_relevance(
            app.client,
            beliefs,
            input_text
        )

        # ----------------------------
        # CONTEXT INJECTION
        # ----------------------------
        state["system_context"] = {
            "memory_summary": memory.get("summary", ""),
            "beliefs": relevant_beliefs
        }

        app.state_manager.save_state(state)

        # ----------------------------
        # DELEGATE BACK TO ENGINE
        # ----------------------------
        return await original_engine(
            input_text=input_text,
            toolbox=toolbox,
            **kwargs
        )

    # replace engine cycle at runtime
    app.engine.run_cycle = patched_cycle