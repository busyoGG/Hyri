#!/bin/bash
SELF_PID=$$

ps -ef | grep clipboard_sync | grep -v grep | grep -v "$SELF_PID" | awk '{print $2}' | xargs -r kill

# 下面放原来的脚本内容
# --------------------
# 防抖变量
last_text=""
last_img_hash=""
temp_file_path="/tmp/sync-img"
ext=""

rm_temp_file(){
    if [[ -f "$temp_file_path" ]]; then
        rm $temp_file_path
    fi
}

temp_file(){
    echo "$temp_file_path.$ext"
}

# X11 → Wayland 同步
x11_to_wayland() {
    while true; do
        # ------- 判断wayland是否复制图片，是则删除x11复制的临时图片 -------
        if [[ -f "$temp_file_path" ]]; then
            clip_types=$(wl-paste --list-types 2>/dev/null || true)
            if [[ "$clip_types" == *"image/png"* ]] || [[ "$clip_types" == *"image/jpeg"* ]]; then
                rm_temp_file
            fi
        fi

        # -------- 图片 --------
        if xclip -selection clipboard -t TARGETS -o 2>/dev/null | grep -q "image/png"; then
            if [[ $(xclip -selection clipboard -t image/png -o 2>/dev/null | wc -c) -gt 0 ]]; then
                x11_img_hash=$(xclip -selection clipboard -t image/png -o | sha256sum | awk '{print $1}')
                if [[ -f "$temp_file_path" ]]; then
                    img_file_hash=$(sha256sum "$temp_file_path" | awk '{print $1}')
                else
                    img_file_hash=""
                fi

                if [[ -n "$x11_img_hash" && "$x11_img_hash" != "$img_file_hash" ]]; then
                    xclip -selection clipboard -t image/png -o > $temp_file_path
                    magic=$(head -c 12 "$temp_file_path" | xxd -p)
                    case "$magic" in
                        89504e470d0a1a0a*) ext="png" ;;
                        474946383761*|474946383961*) ext="gif" ;;
                        ffd8ff*) ext="jpg" ;;
                        52494646*) ext="webp" ;;
                        *) ext="bin" ;;
                    esac
                    path=$(temp_file)
                    echo  "$path"
                    mv "$temp_file_path" "$path"
                    echo -n "file://$path" | wl-copy -t text/uri-list
                fi
                xclip -selection clipboard  -i /dev/null
            fi
        fi

        # -------- 文本 --------
        current_text=$(wl-paste --type text/plain 2>/dev/null || true)
        x11_text=$(xclip -selection clipboard -o 2>/dev/null || true)

        if [[ -n "$x11_text" && "$x11_text" != "$last_text" && "$x11_text" != "$current_text" ]]; then
            echo -n "$x11_text" | wl-copy --type text/plain
            last_text="$x11_text"
            current_text=$(wl-paste --type text/plain 2>/dev/null || true)
            echo "copy to wl $(wl-paste)"
        fi

        if [[ -n "$current_text" && "$current_text" != "$last_text" && "$x11_text" != "$current_text" ]]; then
            echo "$current_text" | xclip -selection clipboard -t UTF8_STRING -i
            last_text="$current_text"
            echo "copy to x11 $(xclip -selection clipboard -o)"
        fi

        cliphist_replay

        sleep 0.5
    done
}

# wl_paste_watcher(){
#     wl-paste --watch bash -c 'cliphist decode $(cliphist list | head -n1) | wl-copy' >/dev/null 2>&1 &
# }

cliphist_replay(){
    if ! wl-paste --list-types >/dev/null 2>&1; then
        cliphist decode $(cliphist list | head -n1) | wl-copy
        echo "cliphist replayed"
    fi
}

# 启动同步服务
# wl_paste_watcher
x11_to_wayland
rm_temp_file
