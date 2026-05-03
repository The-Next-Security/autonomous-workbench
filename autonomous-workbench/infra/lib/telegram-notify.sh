#!/usr/bin/env bash
# telegram-notify.sh
#
# Shared helper for sending alerts from infra scripts to Felipe's Telegram.
# Source this file, then call `telegram_notify "message"`.
#
# Reads bot token and chat id from environment first, falls back to
# ~/.openclaw/openclaw.json. Never logs the token.

set -u

_telegram_read_config() {
  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" ]]; then
    return 0
  fi
  local cfg="${HOME}/.openclaw/openclaw.json"
  if [[ ! -f "${cfg}" ]]; then
    echo "[telegram-notify] openclaw.json not found at ${cfg}" >&2
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    echo "[telegram-notify] jq is required to read bot token" >&2
    return 1
  fi
  TELEGRAM_BOT_TOKEN="$(jq -r '.channels.telegram.botToken // empty' "${cfg}")"
  TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-6739292510}"
  if [[ -z "${TELEGRAM_BOT_TOKEN}" ]]; then
    echo "[telegram-notify] bot token not configured in openclaw.json" >&2
    return 1
  fi
  export TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID
}

telegram_notify() {
  local message="$1"
  if ! _telegram_read_config; then
    return 1
  fi
  curl -sS -X POST \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=${message}" \
    --data-urlencode "disable_web_page_preview=true" \
    >/dev/null
}
