# 1. 更改基底映像檔：從 L4T 版改為官方 x86_64 版
FROM osrf/ros:humble-desktop

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=/usr/local/bin:$PATH

# ================= Basic System Setup ======================
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    wget \
    git \
    vim nano \
    ca-certificates \
    libssl-dev \
    libffi-dev \
    tmux \
    sudo \
    usbutils \
    bash-completion \
    procps \
    zstd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure Python 3
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ====================== 安裝 Ollama ==========================
RUN curl -fsSL https://ollama.com/install.sh | sh
# 安裝 Python 套件
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# ================= Custom User Setup ======================
RUN useradd -ms /bin/bash work
RUN echo "work ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "docker-pc" > /etc/hostname

RUN mkdir -p /workspace && chown work:work /workspace
WORKDIR /workspace

# ================= Custom Shell Environment ======================
RUN echo 'if [ "$DOCKER_ROLE" = "MASTER" ]; then \
    if ! pgrep -x "ollama" > /dev/null; then \
        echo -e "\033[1;36m[Ollama] Starting Ollama server...\033[0m"; \
        ollama serve > /dev/null 2>&1 &\
        sleep 2; \
    fi; \
    export PS1="\[\033[1;35m\][DOCKER MASTER] \[\033[0;33m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "; \
else \
    export PS1="\[\033[1;35m\][DOCKER] \[\033[0;33m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ "; \
fi' >> /home/work/.bashrc
RUN echo "alias ls='ls --color=auto'" >> /home/work/.bashrc
RUN echo "alias ll='ls -alF'" >> /home/work/.bashrc
RUN echo "source /usr/share/bash-completion/bash_completion" >> /home/work/.bashrc

# ================= 針對 C++ 指標開發與除錯 ======================
# USER root
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     gdb \
#     valgrind \
#     libserial-dev \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# ================= ROS2 Setup ======================
RUN echo "export ROS_DOMAIN_ID=10" >> /home/work/.bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /home/work/.bashrc

# ================= Navigation2 ======================
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup \
    ros-humble-backward-ros \
    ros-humble-geographic-msgs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ================= Tmux Config ======================
COPY tmux.conf /root/.tmux.conf
COPY tmux.conf /home/work/.tmux.conf
RUN echo "if command -v tmux &> /dev/null; then tmux ls &> /dev/null || true; fi" >> /home/work/.bashrc

# Finalize
RUN usermod -aG video work
RUN usermod -aG dialout work
USER work
CMD ["bash"]
