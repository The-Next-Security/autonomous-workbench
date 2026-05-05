#!/bin/bash
# OpenClaw daily backup — G-10
# Backs up critical non-git files to /root/.openclaw-backups/
# Runs daily at 01:00 America/Santiago via root crontab
set -euo pipefail

OPENCLAW_DIR="/root/.openclaw"
BACKUP_DIR="/root/.openclaw-backups"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/openclaw-$DATE.tar.gz"
LOG_DIR="/tmp/openclaw"
LOG="$LOG_DIR/backup.log"
KEEP_DAYS=7
TG_CHAT="6739292510"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [backup] $*" >> "$LOG"
}

send_telegram() {
    local msg="$1"
    local token
    token=$(jq -r '.channels.telegram.botToken // empty' "$OPENCLAW_DIR/openclaw.json" 2>/dev/null || true)
    [[ -n "$token" ]] || return 0
    curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
        --data-urlencode "chat_id=${TG_CHAT}" \
        --data-urlencode "text=${msg}" \
        --max-time 10 >/dev/null 2>&1 || true
}

log "Iniciando backup diario..."

# Build file list
BACKUP_ITEMS=(
    "$OPENCLAW_DIR/openclaw.json"
    "$OPENCLAW_DIR/cron/jobs.json"
    "$OPENCLAW_DIR/exec-approvals.json"
    "$OPENCLAW_DIR/handoff"
)

# Scrum: main state files only (skip .bak files)
for f in product-backlog.json sprint-state.json team-state.json sprint-manager.js \
         "OpenClaw-Sistema-Autonomo-Programacion-TNS.md"; do
    [[ -f "$OPENCLAW_DIR/scrum/$f" ]] && BACKUP_ITEMS+=("$OPENCLAW_DIR/scrum/$f")
done
[[ -d "$OPENCLAW_DIR/scrum/sprint-history" ]] && BACKUP_ITEMS+=("$OPENCLAW_DIR/scrum/sprint-history")

# Agent canonicals present on disk (excluding runtime files)
for agent in main roy backend-dev frontend-dev qa-analyst; do
    agent_dir="$OPENCLAW_DIR/agents/$agent/agent"
    for f in AGENTS.md IDENTITY.md SOUL.md TOOLS.md BOOT.md HEARTBEAT.md USER.md; do
        [[ -f "$agent_dir/$f" ]] && BACKUP_ITEMS+=("$agent_dir/$f")
    done
done

# Create archive
if tar -czf "$BACKUP_FILE" --ignore-failed-read "${BACKUP_ITEMS[@]}" 2>>"$LOG"; then
    SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
    find "$BACKUP_DIR" -name "openclaw-*.tar.gz" -mtime +"$KEEP_DAYS" -delete 2>/dev/null || true
    TOTAL=$(find "$BACKUP_DIR" -name "openclaw-*.tar.gz" | wc -l)
    log "OK: $(basename "$BACKUP_FILE") (${SIZE}) — ${TOTAL} backups en disco"
    send_telegram "Backup OpenClaw OK — ${DATE} — ${SIZE} — ${TOTAL}/${KEEP_DAYS} backups"
else
    log "ERROR: tar fallo con codigo $?"
    send_telegram "BACKUP OPENCLAW FALLO — ${DATE} — ver ${LOG}"
    exit 1
fi
