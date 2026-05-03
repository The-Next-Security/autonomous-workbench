#!/usr/bin/env bash
# oauth-audit.sh
#
# Audits that the system runs on OAuth (ChatGPT Plus) exclusively.
# Reports violations; optionally pings Telegram.
#
# Exit codes:
#   0 = clean
#   1 = violation
#   2 = error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/infra/lib/telegram-notify.sh"

ALERT=false
STRICT=false

for arg in "$@"; do
  case "$arg" in
    --alert) ALERT=true ;;
    --strict) STRICT=true ;;
    -h|--help) sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

violations=()
warnings=()

check_env_keys() {
  local var
  for var in OPENAI_API_KEY ANTHROPIC_API_KEY OPENROUTER_API_KEY; do
    if [[ -n "${!var:-}" ]]; then
      violations+=("env var set: ${var}")
    fi
  done
}

check_bashrc_unset() {
  if ! grep -qE '^unset OPENAI_API_KEY' "${HOME}/.bashrc" 2>/dev/null; then
    warnings+=("~/.bashrc does not unset OPENAI_API_KEY at startup")
  fi
}

check_codex_login() {
  if ! command -v codex >/dev/null 2>&1; then
    warnings+=("codex CLI not installed")
    return
  fi
  local status
  status="$(codex login status 2>&1 || true)"
  if ! grep -qi 'ChatGPT' <<<"${status}"; then
    violations+=("codex login is not ChatGPT OAuth: ${status}")
  fi
}

check_openclaw_config() {
  local cfg="${HOME}/.openclaw/openclaw.json"
  if [[ ! -f "${cfg}" ]]; then
    warnings+=("openclaw.json not found")
    return
  fi
  if ! command -v jq >/dev/null 2>&1; then
    warnings+=("jq not installed, skipping openclaw.json inspection")
    return
  fi
  local primary
  primary="$(jq -r '.agents.defaults.model.primary // empty' "${cfg}")"
  if [[ "${primary}" != openai-codex/* ]]; then
    violations+=("primary model is not openai-codex/*: ${primary}")
  fi
}

report() {
  if [[ "${#violations[@]}" -eq 0 && "${#warnings[@]}" -eq 0 ]]; then
    echo "[oauth-audit] clean: OAuth exclusive, no API keys detected"
    exit 0
  fi
  if [[ "${#violations[@]}" -gt 0 ]]; then
    echo "[oauth-audit] VIOLATIONS:" >&2
    printf '  - %s\n' "${violations[@]}" >&2
  fi
  if [[ "${#warnings[@]}" -gt 0 ]]; then
    echo "[oauth-audit] warnings:" >&2
    printf '  - %s\n' "${warnings[@]}" >&2
  fi
  if ${ALERT} && [[ "${#violations[@]}" -gt 0 ]]; then
    local body="oauth-audit: violaciones detectadas"
    body="${body}"$'\n'"$(printf -- '- %s\n' "${violations[@]}")"
    telegram_notify "${body}" || true
  fi
  if [[ "${#violations[@]}" -gt 0 ]]; then exit 1; fi
  if ${STRICT}; then exit 1; fi
  exit 0
}

check_env_keys
check_bashrc_unset
check_codex_login
check_openclaw_config
report
