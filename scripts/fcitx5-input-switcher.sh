#!/bin/bash

echo "switch"
DEVICE="/dev/input/event11"

SWITCHKEYS=("keyboard-us" "rime" "mozc")
INDEX=0

# 获取当前输入法
CURRENT=$(fcitx5-remote -n)

# 找到当前索引
for i in "${!SWITCHKEYS[@]}"; do
    if [[ "${SWITCHKEYS[$i]}" == "$CURRENT" ]]; then
        INDEX=$i
        break
    fi
done

# 更新索引，下次执行切换到下一条
INDEX=$(( (INDEX + 1) % ${#SWITCHKEYS[@]} ))

# 键位自己设定，下面是示例，切换到 EN/CN/JP 分别按下 Ctrl+Alt+1/2/3
SWITCHKEYS=(
    "29:1 56:1 2:1 29:0 56:0 2:0"  # EN
    "29:1 56:1 3:1 29:0 56:0 3:0"  # CN
    "29:1 56:1 4:1 29:0 56:0 4:0"  # JP
)

sleep 0.1
# echo "执行命令 ydotool key ${SWITCHKEYS[$INDEX]}"
ydotool key ${SWITCHKEYS[$INDEX]}


