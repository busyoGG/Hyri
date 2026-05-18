#!/bin/bash

SELF_PID=$$

ps -ef | grep clipboard_sync | grep -v grep | grep -v "$SELF_PID" | awk '{print $2}' | xargs -r kill

# =========================================================
# 状态
# =========================================================

last_text_hash=""
last_img_hash=""
last_uri_hash=""

temp_file_base="/tmp/sync-img"

# =========================================================
# utils
# =========================================================

hash_stdin() {
    sha256sum | awk '{print $1}'
}

hash_file() {
    sha256sum "$1" | awk '{print $1}'
}

is_file_uri() {
    grep -q '^file://'
}

rm_temp_file() {
    rm -f /tmp/sync-img.*
}

temp_file() {
    echo "${temp_file_base}.${ext}"
}

# =========================================================
# cliphist replay
# =========================================================

cliphist_replay() {

    if ! wl-paste --list-types >/dev/null 2>&1; then

        cliphist decode "$(cliphist list | head -n1 | awk '{print $1}')" | \
            wl-copy

        echo "cliphist replayed"
    fi
}

# =========================================================
# 主循环
# =========================================================

x11_to_wayland() {

    while true; do

        # -------------------------------------------------
        # Wayland 已不是图片/文件时
        # 删除旧图片缓存
        # -------------------------------------------------

        wl_types=$(wl-paste --list-types 2>/dev/null || true)

        if ls /tmp/sync-img.* >/dev/null 2>&1; then

            if [[ "$wl_types" != *"image/png"* ]] &&
               [[ "$wl_types" != *"text/uri-list"* ]]; then
                rm_temp_file
            fi
        fi

        # -------------------------------------------------
        # 获取 x11 targets
        # -------------------------------------------------

        x11_targets=$(xclip -selection clipboard -t TARGETS -o 2>/dev/null || true)

        # =================================================
        # 图片同步
        # =================================================

        if echo "$x11_targets" | grep -q "image/png"; then

            TMP_IMG="/tmp/x11-clipboard-img"

            rm -f "$TMP_IMG"

            xclip -selection clipboard \
                -t image/png \
                -o > "$TMP_IMG" 2>/dev/null

            if [[ -s "$TMP_IMG" ]]; then

                x11_img_hash=$(hash_file "$TMP_IMG")

                if [[ "$x11_img_hash" != "$last_img_hash" ]]; then

                    magic=$(head -c 12 "$TMP_IMG" | xxd -p)

                    case "$magic" in
                        89504e470d0a1a0a*) ext="png" ;;
                        474946383761*|474946383961*) ext="gif" ;;
                        ffd8ff*) ext="jpg" ;;
                        52494646*) ext="webp" ;;
                        *) ext="bin" ;;
                    esac

                    path=$(temp_file)

                    mv "$TMP_IMG" "$path"

                    printf 'file://%s\r\n' "$path" | \
                        wl-copy -t text/uri-list

                    last_img_hash="$x11_img_hash"

                    echo "x11 image -> wl"
                fi
            fi
        fi

        # =================================================
        # 文件同步
        # =================================================

        x11_uri=$(xclip -selection clipboard \
            -t text/uri-list \
            -o 2>/dev/null || true)

        wl_uri=$(wl-paste \
            --type text/uri-list 2>/dev/null || true)

        # -------------------------------------------------
        # X11 -> WL
        # -------------------------------------------------

        if echo "$x11_uri" | is_file_uri; then

            uri_hash=$(printf "%s" "$x11_uri" | hash_stdin)

            if [[ "$uri_hash" != "$last_uri_hash" &&
                  "$x11_uri" != "$wl_uri" ]]; then

                printf "%s" "$x11_uri" | \
                    wl-copy -t text/uri-list

                last_uri_hash="$uri_hash"

                echo "x11 file -> wl"
            fi
        fi

        # -------------------------------------------------
        # WL -> X11
        # -------------------------------------------------

        if echo "$wl_uri" | is_file_uri; then

            uri_hash=$(printf "%s" "$wl_uri" | hash_stdin)

            if [[ "$uri_hash" != "$last_uri_hash" &&
                  "$wl_uri" != "$x11_uri" ]]; then

                printf "%s" "$wl_uri" | \
                    xclip -selection clipboard \
                    -t text/uri-list -i

                last_uri_hash="$uri_hash"

                echo "wl file -> x11"
            fi
        fi

        # =================================================
        # 文本同步
        # =================================================

        current_text=$(wl-paste \
            --type text/plain 2>/dev/null || true)

        x11_text=$(xclip \
            -selection clipboard \
            -o 2>/dev/null || true)

        # 跳过 file uri
        if echo "$current_text" | is_file_uri; then
            current_text=""
        fi

        if echo "$x11_text" | is_file_uri; then
            x11_text=""
        fi

        # -------------------------------------------------
        # X11 -> WL
        # -------------------------------------------------

        if [[ -n "$x11_text" &&
              "$x11_text" != "$current_text" ]]; then

            text_hash=$(printf "%s" "$x11_text" | hash_stdin)

            if [[ "$text_hash" != "$last_text_hash" ]]; then

                printf "%s" "$x11_text" | \
                    wl-copy --type text/plain

                last_text_hash="$text_hash"

                echo "copy to wl"
            fi
        fi

        # -------------------------------------------------
        # WL -> X11
        # -------------------------------------------------

        if [[ -n "$current_text" &&
              "$x11_text" != "$current_text" ]]; then

            text_hash=$(printf "%s" "$current_text" | hash_stdin)

            if [[ "$text_hash" != "$last_text_hash" ]]; then

                printf "%s" "$current_text" | \
                    xclip -selection clipboard \
                    -t UTF8_STRING -i

                last_text_hash="$text_hash"

                echo "copy to x11"
            fi
        fi

        cliphist_replay

        sleep 0.3
    done
}

# =========================================================
# 启动
# =========================================================

x11_to_wayland

rm_temp_file