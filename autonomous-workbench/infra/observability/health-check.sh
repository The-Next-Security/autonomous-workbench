#!/usr/bin/env bash
# health-check.sh
#
# Composite health check of the autonomous system. Runs silently if
# everything is OK; sends a single Telegram message summarizing any
# failures.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/infra/lib/telegram-notify.sh"

issues=()

check_gateway() {
  local state
  state="$(systemctl --user is-active openclaw-gateway 2>/dev/null || true)"
  if [[ "${state}" != "active" ]]; then
    issues+=("gateway not active: ${state}")
  fi
}

check_disk() {
  local pct
  pct="$(df -P / | awk 'NR==2 {gsub("%",""); print $5}')"
  if [[ -n "${pct}" && "${pct}" -ge 80 ]]; then
    issues+=("disk usage ${pct}%")
  fi
}

check_oauth() {
  if command -v codex >/dev/null 2>&1; then
    local status
    status="$(codex login status 2>&1 || true)"
    if ! grep -qi 'ChatGPT' <<<"${status}"; then
      issues+=("codex not in ChatGPT OAuth: ${status}")
    fi
  fi
}

check_cron_jobs() {
  local jobs="${HOME}/.openclaw/cron/jobs.json"
  if [[ ! -f "${jobs}" ]]; then
    issues+=("cron jobs.json missing")
    return
  fi
  if command -v jq >/dev/null 2>&1; then
    local disabled
    disabled="$(jq -r '[.jobs[] | select(.enabled == false)] | length' "${jobs}")"
    if [[ -n "${disabled}" && "${disabled}" -gt 0 ]]; then
      issues+=("${disabled} cron job(s) disabled")
    fi
  fi
}

check_api_keys_env() {
  local v
  for v in OPENAI_API_KEY ANTHROPIC_API_KEY OPENROUTER_API_KEY; do
    if [[ -n "${!v:-}" ]]; then
      issues+=("env var set: ${v}")
    fi
  done
}

check_gateway
check_disk
check_oauth
check_cron_jobs
check_api_keys_env

if [[ "${#issues[@]}" -eq 0 ]]; then
  echo "[health-check] OK"
  exit 0
fi

body="health-check encontró ${#issues[@]} problema(s):"
body="${body}"$'\n'"$(printf -- '- %s\n' "${issues[@]}")"
telegram_notify "${body}" || true
echo "[health-check] issues=${#issues[@]}"
printf '  - %s\n' "${issues[@]}" >&2
exit 1
