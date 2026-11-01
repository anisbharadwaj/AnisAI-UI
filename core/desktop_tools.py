import subprocess
import webbrowser
import os
from core.brain import AnisBrain # Placeholder import

def open_application(app_name: str) -> str:
    subprocess.Popen(f"start {app_name}", shell=True)
    return f"Opened {app_name}."

def open_website(url: str) -> str:
    if not url.startswith("http"): url = "https://" + url
    webbrowser.open(url)
    return f"Opened {url}."
