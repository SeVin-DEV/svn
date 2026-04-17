import sys
import os
import json
from datetime import datetime

def save_note(title, content, category="research"):
    base_dir = "state/notes"
    target_dir = os.path.join(base_dir, category.lower())
    os.makedirs(target_dir, exist_ok=True)
    
    safe_title = "".join([c if c.isalnum() else "_" for c in title]).lower()
    file_path = os.path.join(target_dir, f"{safe_title}.md")
    
    template = f"---\nTitle: {title}\nDate: {datetime.now()}\n---\n\n{content}"
    
    try:
        with open(file_path, "w") as f:
            f.write(template)
        return {"status": "success", "file": file_path}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    if len(sys.argv) >= 3:
        print(json.dumps(save_note(sys.argv[1], sys.argv[2])))
