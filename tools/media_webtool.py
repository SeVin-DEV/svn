import subprocess
import json
import os
import sys
import hashlib

def ingest_media(url):
    video_id = hashlib.md5(url.encode()).hexdigest()[:10]
    store_dir = "state/media"
    os.makedirs(store_dir, exist_ok=True)
    
    audio_path = f"{store_dir}/{video_id}.wav"
    frame_pattern = f"{store_dir}/{video_id}_frame_%03d.jpg"

    cmd_yt = [
        "yt-dlp",
        "--extract-audio", "--audio-format", "wav",
        "--postprocessor-args", "ffmpeg:-ar 16000 -ac 1",
        "-o", audio_path, "--print-json", "--no-playlist", url
    ]

    try:
        process = subprocess.run(cmd_yt, capture_output=True, text=True, check=True)
        meta = json.loads(process.stdout.split('\n')[0])
        
        # Slicing 5 visual frames for "vision" context
        duration = meta.get('duration', 60)
        interval = max(1, duration // 6)
        subprocess.run([
            "ffmpeg", "-i", url, "-vf", f"fps=1/{interval}",
            "-frames:v", "5", frame_pattern, "-y"
        ], check=False, capture_output=True)

        return {
            "status": "success",
            "title": meta.get("title"),
            "audio": audio_path,
            "metadata": {"duration": duration, "views": meta.get("view_count")}
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    if len(sys.argv) > 1:
        print(json.dumps(ingest_media(sys.argv[1])))
