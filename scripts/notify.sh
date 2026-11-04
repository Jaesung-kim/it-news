#!/usr/bin/env bash
# 사용법: notify.sh "메시지" | notify.sh --html "HTML 메시지"  — 텔레그램 알림. 어떤 경우에도 exit 0.
export LC_ALL=C.UTF-8  # cron에서도 글자 단위로 자르도록 한다.
ENV_FILE="$HOME/.config/it-news/telegram.env"
HTML=0
if [ "${1:-}" = "--html" ]; then HTML=1; shift; fi
MSG="${1:-}"
[ -n "$MSG" ] || exit 0
[ -r "$ENV_FILE" ] || { echo "notify: $ENV_FILE 없음" >&2; exit 0; }
set -a; . "$ENV_FILE" 2>/dev/null; set +a
[ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ] || { echo "notify: 토큰/채팅ID 없음" >&2; exit 0; }

send() {  # send <본문> [parse_mode]
  curl -s --max-time 20 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=$1" \
    ${2:+--data-urlencode "parse_mode=$2"} \
    --data-urlencode "disable_web_page_preview=true" 2>/dev/null
}

if [ "$HTML" -eq 1 ]; then  # 길이는 format_news.py가 맞춘다. 여기서 자르면 태그가 깨진다.
  case "$(send "$MSG" HTML)" in *'"ok":true'*) exit 0 ;; esac
  echo "notify: HTML 전송 실패, 평문으로 재시도" >&2
  MSG=$(printf '%s' "$MSG" | sed -e 's/<[^>]*>//g' -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&#x27;/'"'"'/g' -e 's/&amp;/\&/g')
fi
case "$(send "${MSG:0:4000}")" in *'"ok":true'*) ;; *) echo "notify: 전송 실패" >&2 ;; esac
exit 0
