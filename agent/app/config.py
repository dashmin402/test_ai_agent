import os
from dotenv import load_dotenv

load_dotenv("/AI_agent_ws/.env")

MODEL_NAME   = os.getenv("MODEL_NAME", "ollama/qwen2.5")
OLLAMA_HOST  = os.getenv("OLLAMA_HOST", "http://localhost:11434")
MAX_STEPS    = int(os.getenv("MAX_STEPS", 20))
SHARED_PATH  = os.getenv("SHARED_PATH", "/AI_agent_ws/shared")
SKILLS_PATH  = "/AI_agent_ws/agent/skills"