import json, os, time
from config import SHARED_PATH

def send_robot_command(action: str, params: dict = {}) -> str:
    """Agent 發送指令給 ROS2 節點"""
    cmd = {
        "action": action,
        "params": params,
        "timestamp": time.time(),
        "status": "pending"
    }
    path = f"{SHARED_PATH}/commands.json"
    json.dump(cmd, open(path, "w"))

    # 等待 ROS2 回報（最多 10 秒）
    for _ in range(20):
        time.sleep(0.5)
        result = json.load(open(path))
        if result.get("status") == "done":
            return result.get("result", "執行完成")
    return "timeout：ROS2 未在 10 秒內回應"

def get_robot_status() -> dict:
    """讀取 ROS2 節點回報的機器人狀態"""
    path = f"{SHARED_PATH}/status.json"
    if os.path.exists(path):
        return json.load(open(path))
    return {"error": "尚未收到狀態資料"}