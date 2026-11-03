#!/usr/bin/env bash
# 사용법: notify.sh "메시지"  — 텔레그램 알림. 어떤 경우에도 exit 0.
ENV_FILE="$HOME/.config/it-news/telegram.env"
MSG="${1:-}"
[ -n "$MSG" ] || exit 0
[ -r "$ENV_FILE" ] || { echo "notify: $ENV_FILE 없음" >&2; exit 0; }
set -a; . "$ENV_FILE" 2>/dev/null; set +a
[ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ] || { echo "notify: 토큰/채팅ID 없음" >&2; exit 0; }
MSG="${MSG:0:4000}"
RESP=$(curl -s --max-time 20 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${MSG}" \
  --data-urlencode "disable_web_page_preview=true" 2>/dev/null) || { echo "notify: 전송 실패" >&2; exit 0; }
case "$RESP" in *'"ok":true'*) ;; *) echo "notify: 전송 실패" >&2 ;; esac
exit 0
