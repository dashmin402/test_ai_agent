import os, re, sys
sys.path.insert(0, "/AI_agent_ws/agent/app")
sys.path.insert(0, "/AI_agent_ws/agent/tools")

from litellm import completion
from config import MODEL_NAME, OLLAMA_HOST, MAX_STEPS, SKILLS_PATH
from ros_tool import send_robot_command, get_robot_status
from search_tool import search

def load_skill(name: str) -> str:
    path = f"{SKILLS_PATH}/{name}.md"
    return open(path).read() if os.path.exists(path) else ""

SYSTEM_PROMPT = f"""
你是一個機器人任務規劃 Agent，可以控制 ROS2 機器人。

可用工具（用 XML 格式呼叫）：
<tool>send_robot_command</tool><args>{{"action":"move","params":{{"speed":0.3}}}}</args>
<tool>get_robot_status</tool><args>{{}}</args>
<tool>search</tool><args>{{"query":"搜尋內容"}}</args>

規則：
1. 每次只呼叫一個工具
2. 移動前必須先確認機器人狀態
3. 完成任務後輸出 <DONE>

{load_skill("ros_skill")}
"""

TOOLS = {
    "send_robot_command": lambda a: send_robot_command(**eval(a)),
    "get_robot_status":   lambda a: get_robot_status(),
    "search":             lambda a: search(**eval(a)),
}

def parse_tool_call(text):
    m = re.search(r'<tool>(.*?)</tool><args>(.*?)</args>', text, re.DOTALL)
    return (m.group(1).strip(), m.group(2).strip()) if m else (None, None)

def run_agent(task: str):
    messages = [{"role": "user", "content": task}]
    for step in range(MAX_STEPS):
        print(f"\n[步驟 {step+1}]")
        resp = completion(
            model=MODEL_NAME,
            api_base=OLLAMA_HOST,
            messages=[{"role":"system","content":SYSTEM_PROMPT}] + messages
        )
        reply = resp.choices[0].message.content
        print(f"Agent: {reply[:300]}")
        messages.append({"role":"assistant","content":reply})

        if "<DONE>" in reply:
            print("\n✓ 任務完成"); break

        tool_name, tool_args = parse_tool_call(reply)
        if tool_name and tool_name in TOOLS:
            result = TOOLS[tool_name](tool_args)
            print(f"工具結果: {result}")
            messages.append({"role":"user","content":f"工具結果：{result}"})

if __name__ == "__main__":
    task = input("請輸入任務：")
    run_agent(task)