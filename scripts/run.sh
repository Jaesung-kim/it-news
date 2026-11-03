#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
LOG_DIR="$HOME/.local/state/it-news"; mkdir -p "$LOG_DIR"
exec 9>"$LOG_DIR/run.lock"; flock -n 9 || { echo "already running"; exit 0; }
cd "$HOME/it-news"
NOTIFY="$HOME/it-news/scripts/notify.sh"
DATE=$(date +%F); if [ "$(date +%H)" -lt 12 ]; then SLOT="오전 08:00"; AMPM="오전"; else SLOT="오후 17:00"; AMPM="오후"; fi
LOG="$LOG_DIR/$DATE.log"
STAGE="준비"

fail() {  # fail <단계명> <로그파일>
  "$NOTIFY" "IT 뉴스 실행 실패 ($1)
$(tail -n 5 "$2" 2>/dev/null)" || true
}
trap 'rc=$?; trap - ERR; fail "$STAGE" "$LOG"; exit $rc' ERR

STAGE="git pull"
git pull --rebase --quiet origin main >> "$LOG" 2>&1 || true

STAGE="RSS 수집"
python3 scripts/fetch_feeds.py >> "$LOG" 2>&1 || echo "$(date) fetch_feeds failed" >> "$LOG"

STAGE="claude"
PROMPT=$(sed -e "s/{DATE}/$DATE/g" -e "s/{SLOT}/$SLOT/g" scripts/prompt.md)
rc=0
timeout 45m claude -p "$PROMPT" --allowedTools "WebFetch,WebSearch,Read,Write,Edit,Glob,Grep" >> "$LOG" 2>&1 || rc=$?
if [ "$rc" -ne 0 ]; then
  if [ "$rc" -eq 124 ]; then fail "claude 타임아웃" "$LOG"; else fail "claude 비정상 종료 rc=$rc" "$LOG"; fi
  exit "$rc"
fi

STAGE="git commit"
git add -A
if git diff --cached --quiet; then
  echo "$(date) no changes"
  "$NOTIFY" "IT 뉴스 $DATE $AMPM: 새 기사 없음"
  exit 0
fi
git commit -q -m "news: $DATE $SLOT"

STAGE="git push"
if ! git push -q origin HEAD:main >> "$LOG" 2>&1; then
  fail "git push" "$LOG"
  exit 1
fi
echo "$(date) pushed"

STAGE="알림"
DAILY="daily/${DATE:0:4}/${DATE:5:2}/$DATE.md"
TITLES=$(git diff HEAD~1 HEAD -- "$DAILY" | sed -n 's/^+### /### /p' || true)
N=$(printf '%s' "$TITLES" | grep -c '^### ' || true)
"$NOTIFY" "IT 뉴스 $DATE $AMPM: 새 기사 ${N}개
$TITLES
https://github.com/Jaesung-kim/it-news/blob/main/$DAILY"
