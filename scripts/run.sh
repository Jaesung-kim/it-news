#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
LOG_DIR="$HOME/.local/state/it-news"; mkdir -p "$LOG_DIR"
exec 9>"$LOG_DIR/run.lock"; flock -n 9 || { echo "already running"; exit 0; }
cd "$HOME/it-news"
git pull --rebase --quiet origin main || true
DATE=$(date +%F); if [ "$(date +%H)" -lt 12 ]; then SLOT="오전 08:00"; else SLOT="오후 17:00"; fi
PROMPT=$(sed -e "s/{DATE}/$DATE/g" -e "s/{SLOT}/$SLOT/g" scripts/prompt.md)
timeout 45m claude -p "$PROMPT" --allowedTools "WebFetch,WebSearch,Read,Write,Edit,Glob,Grep" >> "$LOG_DIR/$DATE.log" 2>&1
git add -A
if git diff --cached --quiet; then echo "$(date) no changes"; exit 0; fi
git commit -q -m "news: $DATE $SLOT"
git push -q origin HEAD:main
echo "$(date) pushed"
