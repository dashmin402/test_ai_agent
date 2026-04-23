#!/bin/bash

# ================= 設定區 =================
IMAGE_NAME="ai_agent"

# ================= 顏色定義 (與 Dockerfile / run.sh 同步) =================
C_TAG='\033[1;35m'  # 靛紫 (標籤)
C_SUCCESS='\033[1;32m' # 薄荷綠 (成功)
C_WARN='\033[1;33m' # 高亮黃 (用於警告與提示)
C_INFO='\033[1;36m'    # 天藍 (資訊)
NC='\033[0m'          # 無顏色

# 統一前綴
PREFIX="${C_TAG}[DOCKER BUILD]${NC}"

# ================= 檢查邏輯 =================

# 1. 檢查映像檔名稱是否合法
if [[ "$IMAGE_NAME" =~ [^a-z0-9_.-] ]]; then
  echo -e "${PREFIX} ${C_TAG}Error:${NC} Image name '${C_TAG}$IMAGE_NAME${NC}' contains invalid characters."
  exit 1
fi

# 2. 檢查目前目錄是否有 Dockerfile
if [ ! -f "Dockerfile" ]; then
  echo -e "${PREFIX} ${C_TAG}Error:${NC} 'Dockerfile' not found in current directory!"
  echo -e "${PREFIX} ${C_INFO}Please make sure you are in the correct folder.${NC}"
  exit 1
fi

# 3. 檢查映像檔是否已存在
if docker images --format "{{.Repository}}" | grep -q "^${IMAGE_NAME}$"; then
  echo -e "${PREFIX} ${C_WARN}Warning:${NC} Image '${C_SUCCESS}$IMAGE_NAME${NC}' already exists."

  # 提示使用者是否覆蓋
  echo -ne "${PREFIX} ${C_WARN}Do you want to overwrite? (Y/n): ${NC}"
  read -r RESPONSE
  RESPONSE=${RESPONSE,,} 

  if [[ "$RESPONSE" == "n" ]]; then
    echo -e "${PREFIX} ${C_TAG}Aborted:${NC} Build cancelled by user."
    exit 1
  else
    echo -e "${PREFIX} ${C_WARN}Info:${NC} Overwriting existing image..."
  fi
fi

# ================= 執行建構 =================

echo -e "${PREFIX} ${C_INFO}Starting build for General PC (x86_64)...${NC}"
echo -e "${PREFIX} ${C_INFO}Target Image: ${C_SUCCESS}$IMAGE_NAME${NC}"
echo -e "${PREFIX} ${C_INFO}--------------------------------------------------${NC}"

# 執行 Docker build (在一般電腦上執行，速度會比 Jetson 快很多)
docker build -t "$IMAGE_NAME" .

# 檢查建構結果
if [ $? -eq 0 ]; then
  echo -e "${PREFIX} ${C_INFO}--------------------------------------------------${NC}"
  echo -e "${PREFIX} ${C_SUCCESS}Success:${NC} Image '${C_INFO}$IMAGE_NAME${NC}' built successfully!"
  echo -e "${PREFIX} ${C_INFO}You can now run: ${C_WARN}./run.sh${NC}"
else
  echo -e "\n${PREFIX} ${C_TAG}Error:${NC} Build failed. Please check the logs above."
  exit 1
fi
