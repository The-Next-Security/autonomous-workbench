#!/usr/bin/env bash
# restore-openclaw.sh
#
# Decrypts and restores an age-encrypted backup into a target directory.
# Default target is a scratch path (safe); pass --target to override.
#
# Usage:
#   restore-openclaw.sh --archive <file> [--target <dir>] [--key <age-private>]
#
# Flags:
#   --archive <file>  Required. Path to <ts>.tar.gz.age.
#   --target <dir>    Where to extract. Default: /tmp/openclaw-restore-<ts>.
#   --key <file>      age private key file. Default: /root/.keys/age-identity.txt.
#   --force-runtime   Restore INTO ~/.openclaw (destructive). Requires confirmation.
#
# Used as part of the backup gate: extract to a scratch dir and list
# contents to verify integrity without overwriting live state.

set -euo pipefail

ARCHIVE=""
TARGET=""
KEY_FILE="${KEY_FILE:-/root/.keys/age-identity.txt}"
FORCE_RUNTIME=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive) ARCHIVE="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --key) KEY_FILE="$2"; shift 2 ;;
    --force-runtime) FORCE_RUNTIME=true; shift ;;
    -h|--help) sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

log() { printf '[restore-openclaw] %s\n' "$*"; }
err() { printf '[restore-openclaw] ERROR: %s\n' "$*" >&2; }

if [[ -z "${ARCHIVE}" ]]; then
  err "--archive is required"
  exit 2
fi
if [[ ! -f "${ARCHIVE}" ]]; then
  err "archive not found: ${ARCHIVE}"
  exit 3
fi
if ! command -v age >/dev/null 2>&1; then
  err "age not installed"
  exit 3
fi
if [[ ! -f "${KEY_FILE}" ]]; then
  err "age private key file not found: ${KEY_FILE}"
  exit 3
fi

if ${FORCE_RUNTIME}; then
  TARGET="${HOME}"
  log "WARNING: --force-runtime selected, will overwrite live ~/.openclaw and ~/.codex/auth.json"
  printf 'Type YES to confirm overwrite: '
  read -r reply
  if [[ "${reply}" != "YES" ]]; then
    err "aborted"
    exit 5
  fi
else
  if [[ -z "${TARGET}" ]]; then
    TARGET="/tmp/openclaw-restore-$(date +%Y%m%d-%H%M%S)"
  fi
  mkdir -p "${TARGET}"
fi

log "decrypting ${ARCHIVE} into ${TARGET}"
age -d -i "${KEY_FILE}" "${ARCHIVE}" | tar -xzf - -C "${TARGET}"

log "restore complete"
log "top-level contents of ${TARGET}:"
ls -la "${TARGET}" | sed 's/^/  /'

if ! ${FORCE_RUNTIME}; then
  log "verification mode: nothing was touched in the live runtime."
  log "to verify further: diff -qr ${TARGET}/.openclaw ~/.openclaw"
fi
