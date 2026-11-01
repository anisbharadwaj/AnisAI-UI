from fastapi import FastAPI
from core.brain import AnisBrain
import uvicorn

app = FastAPI(title="ANIS AI Core", version="3.0.0")
brain = AnisBrain()

@app.get("/")
def read_root():
    return {"status": "ANIS AI Core is online.", "version": "3.0.0"}

@app.post("/chat")
def chat(message: str):
    return {"response": brain.think(message)}

if __name__ == "__main__":
    uvicorn.run("voice_main:app", host="0.0.0.0", port=8000, reload=False)
