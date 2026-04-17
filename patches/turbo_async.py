import core.engine as engine
import asyncio
from concurrent.futures import ThreadPoolExecutor

_executor = ThreadPoolExecutor(max_workers=1)
original_run_cycle = engine.run_cycle

async def async_run_cycle():
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(_executor, original_run_cycle)

# Redirect the engine to the threaded version
engine.run_cycle = async_run_cycle
print('[SYSTEM] Patch integrated: turbo_async.py (Non-blocking Engine active)')