import asyncio

from core.engine import run_cycle
from tools.toolbox import Toolbox


class RuntimeLoop:
    """
    Orchestrates continuous execution of Kayden.
    This is the heartbeat layer.
    """

    def __init__(self, app):
        self.app = app
        self.toolbox = Toolbox()
        self.running = False

    async def start(self):
        self.running = True

        while self.running:
            try:
                await self.tick()
            except Exception as e:
                # fail-safe: runtime never hard-crashes
                self.app.logger.error(f"[RuntimeLoop] Tick error: {e}")

                # optional recovery pause
                await asyncio.sleep(1)

    async def tick(self):
        """
        Single execution cycle.
        """

        state = self.app.state_manager.load_state()

        # pull next user input or queued instruction
        user_input = state.get("pending_input")

        if not user_input:
            await asyncio.sleep(0.1)
            return

        # clear input immediately (prevents double-processing)
        state["pending_input"] = None
        self.app.state_manager.save_state(state)

        # run cognitive engine
        result = await run_cycle(
            app=self.app,
            toolbox=self.toolbox,
            input_text=user_input
        )

        # optionally store output
        state = self.app.state_manager.load_state()
        state.setdefault("outputs", []).append(result)
        self.app.state_manager.save_state(state)

    def stop(self):
        self.running = False