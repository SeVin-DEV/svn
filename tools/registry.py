from typing import Callable, Dict, Any


class ToolRegistry:
    """
    Central registry for all tools.
    Engine and toolbox both depend on this, but it has no runtime logic itself.
    """

    def __init__(self):
        self._tools: Dict[str, Callable] = {}
        self._meta: Dict[str, Dict[str, Any]] = {}

    def register(self, name: str, func: Callable, meta: dict | None = None):
        """
        Register a tool.
        """
        self._tools[name] = func
        self._meta[name] = meta or {}

    def get(self, name: str) -> Callable | None:
        return self._tools.get(name)

    def list_tools(self):
        return list(self._tools.keys())

    def get_meta(self, name: str) -> dict:
        return self._meta.get(name, {})

    def has(self, name: str) -> bool:
        return name in self._tools


# Singleton-style registry instance (simple, not over-engineered)
registry = ToolRegistry()