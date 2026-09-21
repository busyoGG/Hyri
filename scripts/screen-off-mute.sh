#!/usr/bin/env bash

set -Eeuo pipefail

SINK='@DEFAULT_AUDIO_SINK@'
POLL_INTERVAL='0.25'
DPMS_OFF_TIMEOUT='5'

for command in hyprctl jq wpctl flock sleep awk; do
    command -v "$command" >/dev/null 2>&1 || {
        printf '缺少命令：%s\n' "$command" >&2
        exit 1
    }
done

# 快捷键启动时会继承此变量；从终端启动时则选取第一个运行中的实例。
hyprctl_cmd=(hyprctl)
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    instance=$(hyprctl instances | awk '/^instance / { sub(/:$/, "", $2); print $2; exit }')
    if [[ -z "$instance" ]]; then
        printf '找不到运行中的 Hyprland 实例。\n' >&2
        exit 1
    fi
    hyprctl_cmd+=(--instance "$instance")
fi

# 防止重复启动多个等待亮屏的实例。
lock_file="${XDG_RUNTIME_DIR:-/tmp}/screen-off-mute.lock"
exec 9>"$lock_file"
flock -n 9 || exit 0

volume_line=$(wpctl get-volume "$SINK")
volume=$(awk '/^Volume:/ { print $2; exit }' <<< "$volume_line")
if [[ ! "$volume" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    printf '无法读取当前音量：%s\n' "$volume_line" >&2
    exit 1
fi

if [[ "$volume_line" == *'[MUTED]'* ]]; then
    was_muted=1
else
    was_muted=0
fi

audio_muted=0

restore_audio() {
    wpctl set-volume "$SINK" "$volume" >/dev/null
    wpctl set-mute "$SINK" "$was_muted" >/dev/null
    audio_muted=0
}

cleanup() {
    if (( audio_muted )); then
        restore_audio || true
    fi
}
trap cleanup EXIT

monitors_are() {
    local expected="$1"
    "${hyprctl_cmd[@]}" -j monitors 2>/dev/null |
        jq -e --argjson expected "$expected" \
            'length > 0 and all(.[]; .dpmsStatus == ($expected == 1))' \
        >/dev/null 2>&1
}

# 给用户留出一秒取消操作的时间，然后静音并关闭屏幕。
sleep 1
wpctl set-mute "$SINK" 1
audio_muted=1

if ! "${hyprctl_cmd[@]}" dispatch 'hl.dsp.dpms(off)' >/dev/null; then
    restore_audio
    exit 1
fi

# 等待确认 DPMS 已关闭，避免刚发出命令就误判为已亮屏。
off_deadline=$((SECONDS + DPMS_OFF_TIMEOUT))
while (( SECONDS < off_deadline )); do
    if monitors_are 0; then
        break
    fi
    sleep "$POLL_INTERVAL"
done

if ! monitors_are 0; then
    printf 'DPMS 未能确认关闭，已恢复音频。\n' >&2
    restore_audio
    exit 1
fi

# 屏幕重新亮起后，恢复进入脚本前的音量和静音状态。
while ! monitors_are 1; do
    sleep "$POLL_INTERVAL"
done

restore_audio
