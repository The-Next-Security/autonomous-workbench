#!/usr/bin/env bash
# gateway-watchdog.sh
#
# Checks that openclaw-gateway user service is active. If it has been
# inactive for more than THRESHOLD minutes, sends a Telegram alert.
#
# Designed to be invoked by a cron or as a systemd OnFailure hook.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/infra/lib/telegram-notify.sh"

THRESHOLD_MIN="${THRESHOLD_MIN:-5}"
STATE_FILE="${HOME}/.openclaw/logs/gateway-watchdog.state"

mkdir -p "$(dirname "${STATE_FILE}")"

is_active="$(systemctl --user is-active openclaw-gateway 2>/dev/null || true)"

now=$(date +%s)

if [[ "${is_active}" == "active" ]]; then
  rm -f "${STATE_FILE}"
  echo "[gateway-watchdog] active"
  exit 0
fi

if [[ -f "${STATE_FILE}" ]]; then
  first_down=$(cat "${STATE_FILE}")
else
  first_down="${now}"
  echo "${first_down}" > "${STATE_FILE}"
fi

down_seconds=$((now - first_down))
down_min=$((down_seconds / 60))

echo "[gateway-watchdog] state=${is_active} down_for=${down_min}min"

if [[ "${down_min}" -ge "${THRESHOLD_MIN}" ]]; then
  telegram_notify "openclaw-gateway inactivo hace ${down_min} minutos (estado: ${is_active}). Revisar systemctl --user status openclaw-gateway." || true
  exit 1
fi

exit 0
