import sqlite3
from config import Config

class Memory:
    def __init__(self):
        self.conn = sqlite3.connect(Config.DB_PATH, check_same_thread=False)
        self._init_db()
    def _init_db(self):
        cursor = self.conn.cursor()
        cursor.execute('CREATE TABLE IF NOT EXISTS chat_history (id INTEGER PRIMARY KEY AUTOINCREMENT, role TEXT, content TEXT)')
        self.conn.commit()
    def add_message(self, role: str, content: str):
        cursor = self.conn.cursor()
        cursor.execute("INSERT INTO chat_history (role, content) VALUES (?, ?)", (role, content))
        self.conn.commit()
    def get_recent_context(self, limit: int = 10):
        cursor = self.conn.cursor()
        cursor.execute("SELECT role, content FROM chat_history ORDER BY id DESC LIMIT ?", (limit,))
        return [{"role": row[0], "content": row[1]} for row in reversed(cursor.fetchall())]

class AnisBrain:
    def __init__(self):
        self.memory = Memory()
    def think(self, user_input: str) -> str:
        self.memory.add_message("user", user_input)
        return "Anis is processing your request locally."
