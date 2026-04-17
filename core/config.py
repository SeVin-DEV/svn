# core/config.py

import os
from dotenv import load_dotenv


class Config:
    """
    Loads environment configuration.
    This is the ONLY source of runtime constants.
    """

    def __init__(self):
        load_dotenv()

        # Model selection (swappable without code changes)
        self.model_name = os.getenv(
            "MODEL_NAME",
            "moonshotai/kimi-k2-instruct"
        )

        # Debug / runtime flags
        self.debug = os.getenv("DEBUG", "false").lower() == "true"

        # Optional future hooks
        self.plugin_dir = os.getenv("PLUGIN_DIR", "plugins")
        self.tool_dir = os.getenv("TOOL_DIR", "tools")

        # Persistence paths (can be moved later without code edits)
        self.state_path = os.getenv("STATE_PATH", "data/state.json")
        self.memory_path = os.getenv("MEMORY_PATH", "data/memory_summary.json")