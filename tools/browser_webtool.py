import asyncio
import json
import sys
import os
from playwright.async_api import async_playwright

async def browse_and_act(url, action="view", selector=None, value=None):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )
        page = await context.new_page()
        page.set_default_timeout(30000)

        try:
            await page.goto(url, wait_until="domcontentloaded")
            
            status_msg = "Page viewed"
            if action == "click" and selector:
                await page.click(selector)
                status_msg = f"Clicked {selector}"
            elif action == "fill" and selector and value:
                await page.fill(selector, value)
                status_msg = f"Filled {selector}"
            
            await page.wait_for_timeout(1000)

            # Snapshots for 'sensory' feedback
            snap_path = "state/media/last_browse_snap.png"
            os.makedirs("state/media", exist_ok=True)
            await page.screenshot(path=snap_path)

            return {
                "status": "success",
                "url": page.url,
                "title": await page.title(),
                "snapshot": snap_path,
                "text_snippet": (await page.content())[:2000]
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}
        finally:
            await browser.close()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        url_in = sys.argv[1]
        act_in = sys.argv[2] if len(sys.argv) > 2 else "view"
        print(json.dumps(asyncio.run(browse_and_act(url_in, act_in))))
