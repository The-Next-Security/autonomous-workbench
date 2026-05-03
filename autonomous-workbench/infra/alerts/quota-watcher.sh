#!/usr/bin/env bash
# quota-watcher.sh
#
# Approximate ChatGPT Plus quota monitor. Reads codex usage indicators
# when available and alerts if near the rolling-window limit.
#
# Given that OpenAI does not expose a public quota API for ChatGPT Plus
# OAuth sessions, this script uses signals that codex CLI exposes (via
# `codex login status` and, when present, `codex usage`). If neither
# returns usable data, the script reports gracefully and exits 0.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/infra/lib/telegram-notify.sh"

THRESHOLD_PCT="${THRESHOLD_PCT:-80}"

if ! command -v codex >/dev/null 2>&1; then
  echo "[quota-watcher] codex CLI missing, skipping"
  exit 0
fi

if codex usage --help >/dev/null 2>&1; then
  usage_json="$(codex usage --json 2>/dev/null || true)"
  if [[ -n "${usage_json}" ]] && command -v jq >/dev/null 2>&1; then
    pct="$(echo "${usage_json}" | jq -r '.rollingWindow.usedPct // empty')"
    if [[ -n "${pct}" ]]; then
      pct_int="${pct%.*}"
      if [[ "${pct_int}" -ge "${THRESHOLD_PCT}" ]]; then
        telegram_notify "quota-watcher: cuota ChatGPT Plus al ${pct_int}% de la ventana. Pausar sub-agentes no críticos si hace falta." || true
        exit 1
      fi
      echo "[quota-watcher] quota at ${pct_int}%, below threshold ${THRESHOLD_PCT}%"
      exit 0
    fi
  fi
fi

echo "[quota-watcher] codex does not expose usage data, cannot compute quota in this version"
exit 0
