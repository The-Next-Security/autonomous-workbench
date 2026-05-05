#!/bin/bash
# OpenClaw KPI report generator — G-11
# Produces /root/.openclaw/kpis/kpis-YYYY-MM-DD.md
# Runs daily at 00:55 America/Santiago via root crontab
set -euo pipefail

OPENCLAW_DIR="/root/.openclaw"
KPI_DIR="$OPENCLAW_DIR/kpis"
DATE=$(date +%Y-%m-%d)
TIME=$(date '+%Y-%m-%d %H:%M:%S')
OUT="$KPI_DIR/kpis-${DATE}.md"

mkdir -p "$KPI_DIR"

# --- Gateway status ---
GW_STATUS=$(systemctl is-active openclaw-gateway 2>/dev/null || echo "unknown")
GW_UPTIME=$(systemctl show openclaw-gateway --property=ActiveEnterTimestamp --value 2>/dev/null | sed 's/ [A-Z]*$//' || echo "n/a")

# --- Model quotas ---
now_ms=$(date +%s%3N)

check_model_state() {
    local file="$1"
    [[ -f "$file" ]] || { echo "  - archivo no encontrado"; return; }
    python3 - "$file" "$now_ms" <<'EOF'
import sys, json
path, now_ms = sys.argv[1], int(sys.argv[2])
try:
    d = json.load(open(path))
except Exception as e:
    print(f"  - error leyendo: {e}")
    sys.exit(0)
stats = d.get("usageStats", {})
if not stats:
    print("  - sin modelos registrados")
    sys.exit(0)
lines = []
for model_id, info in stats.items():
    disabled = info.get("disabledUntil", 0)
    cooldown = info.get("cooldownUntil", 0)
    errors   = info.get("errorCount", 0)
    if disabled and disabled > now_ms:
        remaining = (disabled - now_ms) // 1000
        lines.append(f"  - {model_id}: DISABLED ({remaining}s restantes)")
    elif cooldown and cooldown > now_ms:
        remaining = (cooldown - now_ms) // 1000
        lines.append(f"  - {model_id}: cooldown ({remaining}s restantes)")
    else:
        lines.append(f"  - {model_id}: OK (errors={errors})")
print("\n".join(lines))
EOF
}

ANIBAL_MODELS=$(check_model_state "$OPENCLAW_DIR/agents/main/agent/auth-state.json")
ROY_MODELS=$(check_model_state "$OPENCLAW_DIR/agents/roy/agent/auth-state.json")

# --- Last backup ---
LAST_BACKUP=$(ls -1t /root/.openclaw-backups/openclaw-*.tar.gz 2>/dev/null | head -1)
if [[ -n "$LAST_BACKUP" ]]; then
    BACKUP_SIZE=$(du -sh "$LAST_BACKUP" | cut -f1)
    BACKUP_DATE=$(basename "$LAST_BACKUP" | sed 's/openclaw-\([0-9]*\)-\([0-9]*\)\.tar\.gz/\1 \2/' | \
                  awk '{d=$1; t=$2; printf "%s-%s-%s %s:%s:%s", substr(d,1,4),substr(d,5,2),substr(d,7,2),substr(t,1,2),substr(t,3,2),substr(t,5,2)}')
    BACKUP_INFO="$BACKUP_DATE ($BACKUP_SIZE)"
    BACKUP_COUNT=$(find /root/.openclaw-backups -name "openclaw-*.tar.gz" | wc -l)
else
    BACKUP_INFO="sin backups"
    BACKUP_COUNT=0
fi

# --- Disk ---
DISK_INFO=$(df -h /root | awk 'NR==2{printf "usado: %s / total: %s (%s usado)", $3, $2, $5}')

# --- Sprint progress ---
SPRINT_INFO="sin sprint activo"
if [[ -f "$OPENCLAW_DIR/scrum/sprint-state.json" ]]; then
    SPRINT_INFO=$(python3 - "$OPENCLAW_DIR/scrum/sprint-state.json" <<'EOF'
import sys, json
try:
    d = json.load(open(sys.argv[1]))
    sid     = d.get("sprintId", "?")
    status  = d.get("status", "?")
    backlog = len(d.get("backlog", []))
    in_prog = len(d.get("inProgress", []))
    done    = len(d.get("done", []))
    impede  = len(d.get("impediments", []))
    total   = backlog + in_prog + done
    print(f"Sprint {sid} ({status}) — {done}/{total} items done, {in_prog} en curso, {impede} impedimentos")
except Exception as e:
    print(f"error: {e}")
EOF
)
fi

# --- Active crons ---
CRON_LIST=$(/usr/bin/node /usr/lib/node_modules/openclaw/openclaw.mjs cron list --json 2>/dev/null | \
    python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    jobs = d.get('jobs', [])
    for j in jobs:
        name    = j.get('name','?')
        enabled = 'activo' if j.get('enabled') else 'deshabilitado'
        sched   = j.get('schedule',{}).get('expr','?')
        tz      = j.get('schedule',{}).get('tz','')
        agent   = j.get('agentId','?')
        print(f'  - {name}: {sched} {tz} [{enabled}] → {agent}')
except Exception as e: print(f'  - error: {e}')
" 2>/dev/null || echo "  - no disponible")

# --- Write KPI file ---
cat > "$OUT" <<KPIEOF
# OpenClaw KPIs — ${DATE}

> Generado: ${TIME}

## Gateway

| Campo | Valor |
|-------|-------|
| Estado | ${GW_STATUS} |
| Activo desde | ${GW_UPTIME} |

## Modelos

**Aníbal (main):**
${ANIBAL_MODELS}

**Roy:**
${ROY_MODELS}

## Backup

| Campo | Valor |
|-------|-------|
| Último backup | ${BACKUP_INFO} |
| Backups en disco | ${BACKUP_COUNT}/7 |

## Disco

${DISK_INFO}

## Sprint

${SPRINT_INFO}

## Crons activos

${CRON_LIST}
KPIEOF

echo "KPI generado: $OUT"
