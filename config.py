import os
class Config:
    OLLAMA_MODEL = os.getenv("ANIS_MODEL", "qwen2.5:7b")
    OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
    DB_PATH = "anis_memory.db"
    SYSTEM_PROMPT = "You are ANIS, a highly intelligent, professional, and friendly personal AI assistant."
