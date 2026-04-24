#!/usr/bin/env bash
# oauth-status-check.sh
#
# Runs `codex login status`. If the session is not ChatGPT OAuth or is
# expired, sends a Telegram alert asking for manual re-login.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/infra/lib/telegram-notify.sh"

if ! command -v codex >/dev/null 2>&1; then
  telegram_notify "oauth-status-check: codex CLI no está instalada en la VPS." || true
  exit 2
fi

status="$(codex login status 2>&1 || true)"

if grep -qi 'ChatGPT' <<<"${status}"; then
  echo "[oauth-status-check] OK: ${status}"
  exit 0
fi

telegram_notify "oauth-status-check: codex login NO está en modo ChatGPT. Estado: ${status}. Ejecutar 'codex login' manualmente y revisar platform.openai.com/api-keys para revocar keys auto-creadas." || true
echo "[oauth-status-check] alerta enviada"
exit 1
