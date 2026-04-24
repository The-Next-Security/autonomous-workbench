#!/usr/bin/env bash
# compute-kpis.sh
#
# Produces docs/KPIS.md with a snapshot of the current state of the
# autonomous system. Uses GitHub API (gh) for PR data, git log for
# repo activity, and openclaw cron/logs where available.
#
# Intended to be run by cron weekly or on demand. Overwrites docs/KPIS.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUT="${REPO_ROOT}/docs/KPIS.md"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not installed" >&2
  exit 2
fi

REPOS=(
  "The-Next-Security/autonomous-workbench"
  "The-Next-Security/scrum-files"
  "The-Next-Security/agents-files"
)

now_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

{
  echo "# KPIS — Snapshot del sistema autónomo"
  echo
  echo "Generado automáticamente por \`infra/observability/compute-kpis.sh\`."
  echo
  echo "- Fecha del snapshot: ${now_utc}"
  echo "- Versión objetivo: 1.0.0"
  echo
  echo "## Pull Requests por repositorio (últimos 30 días)"
  echo
  echo "| Repo | Abiertos | Mergeados (30d) | Cerrados sin merge (30d) |"
  echo "|------|----------|-----------------|--------------------------|"

  since_date="$(date -u -d '30 days ago' '+%Y-%m-%dT%H:%M:%SZ')"

  for repo in "${REPOS[@]}"; do
    open=$(gh pr list --repo "${repo}" --state open --json number | jq 'length' 2>/dev/null || echo "?")
    merged=$(gh pr list --repo "${repo}" --state merged --search "merged:>=${since_date}" --json number 2>/dev/null | jq 'length' || echo "?")
    closed=$(gh pr list --repo "${repo}" --state closed --search "closed:>=${since_date} is:unmerged" --json number 2>/dev/null | jq 'length' || echo "?")
    echo "| ${repo} | ${open} | ${merged} | ${closed} |"
  done

  echo
  echo "## Gateway health"
  echo
  local_state="$(systemctl --user is-active openclaw-gateway 2>/dev/null || echo unknown)"
  echo "- systemd user service \`openclaw-gateway\`: **${local_state}**"

  echo
  echo "## OAuth status"
  echo
  if command -v codex >/dev/null 2>&1; then
    codex_state="$(codex login status 2>&1 | head -1 || true)"
    echo "- codex login status: ${codex_state}"
  else
    echo "- codex CLI no instalada."
  fi

  echo
  echo "## Cron jobs configurados"
  echo
  jobs_file="${HOME}/.openclaw/cron/jobs.json"
  if [[ -f "${jobs_file}" ]] && command -v jq >/dev/null 2>&1; then
    count=$(jq -r '.jobs | length' "${jobs_file}")
    enabled=$(jq -r '[.jobs[] | select(.enabled == true)] | length' "${jobs_file}")
    echo "- Total: ${count}"
    echo "- Activos: ${enabled}"
    echo
    echo "| Nombre | Activo | Schedule |"
    echo "|--------|--------|----------|"
    jq -r '.jobs[] | "| \(.name) | \(.enabled) | \(.schedule.expr // .schedule.at // "n/a") |"' "${jobs_file}"
  else
    echo "- Archivo jobs.json no disponible o jq no instalado."
  fi

  echo
  echo "## Disk usage (raíz)"
  echo
  df -hP / | awk 'NR==1 {print "| Filesystem | Size | Used | Avail | Use% | Mounted |"; print "|---|---|---|---|---|---|"} NR>1 {print "| " $1 " | " $2 " | " $3 " | " $4 " | " $5 " | " $6 " |"}'

  echo
  echo "## Notas"
  echo
  echo "- KPIs de velocity de sprint se calculan desde \`~/.openclaw/scrum/sprint-state.json\` en iteraciones posteriores."
  echo "- Métricas de defect-escape rate y time-to-PR requieren la tabla de release de la 1.0.0 ya estabilizada."
  echo "- Este documento se regenera en cada ejecución del script."

} > "${OUT}"

echo "[compute-kpis] wrote ${OUT}"
