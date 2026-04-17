# core/app.py

class AppContext:
    """
    Central runtime container.
    Everything attaches here.
    Nothing should exist outside it long-term.
    """

    def __init__(self):
        self.client = None
        self.config = None

        self.state = None
        self.memory = None

        self.tools = None
        self.plugins = None
        self.patches = None

    # -----------------------------

    def attach(self, key: str, obj):
        """
        Safe dynamic attachment point.
        Used during bootstrap.
        """
        setattr(self, key, obj)

    # -----------------------------

    def get(self, key: str):
        """
        Safe access layer (optional but useful later).
        """
        return getattr(self, key, None)