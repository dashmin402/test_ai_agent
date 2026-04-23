#!/bin/bash

IMAGE_NAME="ai_agent"
CONTAINER_NAME="ai_agent_dev"

# ================= 顏色定義 (森林與星空系列) =================
C_TAG='\033[1;35m'    # 靛紫 (標籤)
C_SUCCESS='\033[1;32m' # 薄荷綠 (成功)
C_WARN='\033[1;33m'    # 橘黃 (警告)
C_INFO='\033[1;36m'    # 天藍 (資訊)
NC='\033[0m'          # 無顏色

MASTER_PREFIX="${C_TAG}[DOCKER MASTER]${NC}"
SLAVE_PREFIX="${C_TAG}[DOCKER SLAVE]${NC}"
MOUNT_DIR=$(dirname "$(cd "$(dirname "$0")" && pwd)")

# 偵測容器狀態
# 取得正在執行的容器
CONTAINER_RUNNING=$(docker ps --format '{{.Names}}' | grep -w "^${CONTAINER_NAME}$")
# 取得所有的容器（包含已停止的）
CONTAINER_EXISTS=$(docker ps -a --format '{{.Names}}' | grep -w "^${CONTAINER_NAME}$")

# ================= 執行邏輯 =================

# 1. 授權 X11 顯示權限
xhost +local:docker > /dev/null

if [ -n "$CONTAINER_RUNNING" ]; then
    # --- 情況 1：容器正在運行 (Slave 模式) ---
    echo -e "${SLAVE_PREFIX} ${C_SUCCESS}Joining as Slave Session...${NC}"
    
    docker exec -it -e DOCKER_ROLE=SLAVE ${CONTAINER_NAME} bash

    echo -e "\n${SLAVE_PREFIX} ${C_WARN}Slave session ended.${NC}"

elif [ -n "$CONTAINER_EXISTS" ]; then
    # --- 情況 2：容器存在但未啟動 (Master 模式 - Start) ---
    echo -e "${MASTER_PREFIX} ${C_INFO}Starting existing Master Session...${NC}"
    
    # 使用 start -ai 來啟動並附加到原本的互動式終端機
    docker start -ai ${CONTAINER_NAME}

    echo -e "\n${MASTER_PREFIX} ${C_WARN}Master session ended. Container is stopped but NOT removed.${NC}"

else
    # --- 情況 3：容器不存在 (Master 模式 - Run) ---
    echo -e "${MASTER_PREFIX} ${C_INFO}Creating and Starting Master Session...${NC}"

    # 移除了 --rm 參數，使得容器關閉後不會被刪除
    docker run -it \
        --name ${CONTAINER_NAME} \
        --gpus all \
        -v /dev:/dev \
        -v "$MOUNT_DIR":/workspace \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/.Xauthority:/home/work/.Xauthority \
        -e DISPLAY=$DISPLAY \
        -e QT_X11_NO_MITSHM=1 \
        -e XAUTHORITY=/home/work/.Xauthority \
        --net=host \
        --ipc=host \
        --privileged \
        -e DOCKER_ROLE=MASTER \
        --env-file ~/docker_ws/AI_agent_ws/.env \
        "$IMAGE_NAME"
        
    echo -e "\n${MASTER_PREFIX} ${C_WARN}Master session ended. Container is stopped but NOT removed.${NC}"
fi
