#!/usr/bin/env bash
set -uo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
export LC_ALL=C.UTF-8
LOG_DIR="$HOME/.local/state/it-news"; mkdir -p "$LOG_DIR"
exec 9>"$LOG_DIR/run.lock"; flock -n 9 || { echo "already running"; exit 0; }
cd "$HOME/it-news" || exit 1
NOTIFY="$HOME/it-news/scripts/notify.sh"
BLOB_URL="https://github.com/Jaesung-kim/it-news/blob/main"
DATE=$(date +%F); if [ "$(date +%H)" -lt 12 ]; then SLOT="오전 07:30"; AMPM="오전"; else SLOT="오후 17:00"; AMPM="오후"; fi
LOG="$LOG_DIR/$DATE.log"

fail() {  # fail <사유>
  "$NOTIFY" "뉴스 실행 실패 ($1)
$(tail -n 5 "$LOG" 2>/dev/null)" || true
}

discard_changes() {  # 실패한 분야의 작업물이 다음 분야 커밋에 섞이지 않게 한다.
  git reset -q --hard HEAD >> "$LOG" 2>&1
  git clean -fdq -- articles daily data >> "$LOG" 2>&1
}

render_prompt() {  # render_prompt <키> <이름> <최대 개수> <일별 파일> <항목 파일> <상태 파일>
  local p rules
  p=$(cat scripts/prompt_base.md)
  rules=$(cat "scripts/rules/$1.md")
  p=${p//\{RULES\}/"$rules"}
  p=${p//\{DATE\}/"$DATE"}
  p=${p//\{SLOT\}/"$SLOT"}
  p=${p//\{CATEGORY\}/"$2"}
  p=${p//\{MAX\}/"$3"}
  p=${p//\{DAILY\}/"$4"}
  p=${p//\{ITEMS\}/"$5"}
  p=${p//\{STATUS\}/"$6"}
  printf '%s' "$p"
}

run_category() {  # run_category <키> <아이콘> <이름> <최대 개수>
  local key="$1" icon="$2" name="$3" max="$4" suffix="" rc=0 daily prompt
  [ "$key" = "it" ] || suffix="-$key"
  daily="daily/${DATE:0:4}/${DATE:5:2}/$DATE$suffix.md"
  prompt=$(render_prompt "$key" "$name" "$max" "$daily" ".cache/feeds/items$suffix.tsv" ".cache/feeds/status$suffix.tsv")

  echo "$(date) [$key] start" >> "$LOG"
  timeout 45m claude -p "$prompt" --allowedTools "WebFetch,WebSearch,Read,Write,Edit,Glob,Grep" >> "$LOG" 2>&1 </dev/null || rc=$?
  if [ "$rc" -ne 0 ]; then
    discard_changes
    if [ "$rc" -eq 124 ]; then fail "$name: claude 타임아웃"; else fail "$name: claude 비정상 종료 rc=$rc"; fi
    return 1
  fi

  git add -A >> "$LOG" 2>&1
  if git diff --cached --quiet; then
    echo "$(date) [$key] no changes" >> "$LOG"
    "$NOTIFY" "$icon $name $DATE $AMPM: 새 기사 없음"
    return 0
  fi
  if ! git commit -q -m "news($key): $DATE $SLOT" >> "$LOG" 2>&1; then
    discard_changes
    fail "$name: git commit"
    return 1
  fi
  if ! git push -q origin HEAD:main >> "$LOG" 2>&1; then
    fail "$name: git push"
    return 1
  fi
  echo "$(date) [$key] pushed" >> "$LOG"

  local parts=() part
  mapfile -d '' -t parts < <(git diff HEAD~1 HEAD -- "$daily" | python3 scripts/format_news.py \
    --icon "$icon" --name "$name" --date "$DATE" --ampm "$AMPM" --daily "$daily" --blob-url "$BLOB_URL" 2>> "$LOG")
  if [ "${#parts[@]}" -eq 0 ]; then
    "$NOTIFY" "$icon $name $DATE $AMPM: 새 기사 있음
$BLOB_URL/$daily"
    return 0
  fi
  for part in "${parts[@]}"; do "$NOTIFY" --html "$part"; done
}

git pull --rebase --quiet origin main >> "$LOG" 2>&1 || echo "$(date) git pull failed" >> "$LOG"
python3 scripts/fetch_feeds.py >> "$LOG" 2>&1 || echo "$(date) fetch_feeds failed" >> "$LOG"

# 분야 순서가 중복 처리 순서다. 앞 분야에 실린 사건은 뒤 분야에서 제외된다.
mapfile -t CATEGORIES < <(grep -v '^#' scripts/categories.tsv)
OVERALL=0
for row in "${CATEGORIES[@]}"; do
  IFS=$'\t' read -r KEY ICON NAME MAX <<< "$row"
  run_category "$KEY" "$ICON" "$NAME" "$MAX" || OVERALL=1
done
exit "$OVERALL"
