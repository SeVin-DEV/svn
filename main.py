# main.py (KERNEL - DO NOT PUT LOGIC HERE)

import os
import asyncio
from dotenv import load_dotenv

from core.app import AppContext
from core.engine import run_cycle
from patches.loader import load_patches
from tools.toolbox import Toolbox
from memory.memory import Memory


# ----------------------------
# BOOTSTRAP
# ----------------------------

def bootstrap():
    load_dotenv()

    app = AppContext(
        model=os.getenv("MODEL_NAME"),
        api_key=os.getenv("API_KEY"),
    )

    app.state = app.state_manager.load_state()

    # core subsystems
    app.memory = Memory(app)
    app.toolbox = Toolbox(app)

    return app


# ----------------------------
# SYSTEM INITIALIZATION
# ----------------------------

def initialize(app: AppContext):
    # Load patches (hook system)
    load_patches(app)

    # Load tools
    app.toolbox.discover_tools()

    # Load memory state
    app.memory.load()

    return app


# ----------------------------
# MAIN DISPATCH LOOP
# ----------------------------

async def chat_loop(app: AppContext):

    while True:
        user_input = await asyncio.to_thread(input, ">>> ")

        if user_input.strip().lower() in ["exit", "quit"]:
            break

        # SINGLE ENTRY POINT INTO SYSTEM
        response = await run_cycle(app, user_input)

        print("\n", response, "\n")


# ----------------------------
# ENTRY POINT
# ----------------------------

def main():
    app = bootstrap()
    initialize(app)

    asyncio.run(chat_loop(app))


if __name__ == "__main__":
    main()Still