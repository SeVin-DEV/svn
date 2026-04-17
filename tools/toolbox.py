from typing import Any, Dict
from tools.registry import registry


class ToolExecutionError(Exception):
    pass


class Toolbox:
    """
    Executes tools registered in ToolRegistry.
    Keeps engine free of execution details.
    """

    def __init__(self):
        self.registry = registry

    async def run(self, name: str, payload: Dict[str, Any] | None = None):
        payload = payload or {}

        tool = self.registry.get(name)

        if not tool:
            raise ToolExecutionError(f"Tool not found: {name}")

        try:
            # support both sync and async tools
            if callable(tool):
                result = tool(payload)

                if hasattr(result, "__await__"):
                    result = await result

                return {
                    "tool": name,
                    "ok": True,
                    "result": result
                }

        except Exception as e:
            return {
                "tool": name,
                "ok": False,
                "error": str(e)
            }