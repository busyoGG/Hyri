#!/bin/bash

# 设置截图文件路径
TPATH="/tmp"

FILENAME="screenshot_qrcode.png"

SCREENSHOT_PATH="$TPATH/$FILENAME"

# 使用 grim 区域截图并保存，注意 -o 指定输出路径
wayfreeze --enable-keyboard --hide-cursor --after-freeze-cmd "sh -c '
    grim -g \"\$(slurp)\" \"$SCREENSHOT_PATH\";
    killall wayfreeze
'"

# 强制同步
echo "截图完成"

sleep 0.1

QRCODE=$(zbarimg $SCREENSHOT_PATH | cut -d':' -f2-)

echo "$QRCODE" | wl-copy  --type text/plain # 复制到剪贴板
notify-send -a "QR-CODE 结果" "" "$QRCODE"  # 显示通知
