#!/usr/bin/env bash
# backup-openclaw.sh
#
# Creates a daily age-encrypted backup of the OpenClaw runtime and
# Codex auth. Rotates keeping the 7 most recent archives.
#
# Destination: /var/backups/openclaw/<YYYYMMDD-HHMMSS>.tar.gz.age
# Recipients file: /root/.keys/age-recipients.txt (one recipient per line)
#
# Flags:
#   --dry-run   Report actions without writing.

set -euo pipefail

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

DEST_DIR="${DEST_DIR:-/var/backups/openclaw}"
RECIPIENTS_FILE="${RECIPIENTS_FILE:-/root/.keys/age-recipients.txt}"
KEEP=7

SOURCES=(
  "${HOME}/.openclaw"
  "${HOME}/.codex/auth.json"
)

log() { printf '[backup-openclaw] %s\n' "$*"; }
err() { printf '[backup-openclaw] ERROR: %s\n' "$*" >&2; }

ensure_tools() {
  if ! command -v age >/dev/null 2>&1; then
    err "age not installed. Install with: apt-get install -y age"
    exit 3
  fi
  if ! command -v tar >/dev/null 2>&1; then
    err "tar not installed"
    exit 3
  fi
}

ensure_recipients() {
  if [[ ! -f "${RECIPIENTS_FILE}" ]]; then
    err "recipients file missing: ${RECIPIENTS_FILE}"
    err "create it with at least one age recipient (age-keygen -o key.txt; take the public line)"
    exit 3
  fi
}

ensure_dest() {
  if [[ ! -d "${DEST_DIR}" ]]; then
    if ${DRY_RUN}; then
      log "would create ${DEST_DIR}"
    else
      mkdir -p "${DEST_DIR}"
      chmod 700 "${DEST_DIR}"
    fi
  fi
}

build_archive() {
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  local out="${DEST_DIR}/${ts}.tar.gz.age"
  local tar_args=()
  for src in "${SOURCES[@]}"; do
    if [[ -e "${src}" ]]; then
      tar_args+=("${src}")
    else
      log "source missing, skipped: ${src}"
    fi
  done
  if [[ "${#tar_args[@]}" -eq 0 ]]; then
    err "no sources to back up"
    exit 4
  fi
  if ${DRY_RUN}; then
    log "would create ${out} from: ${tar_args[*]}"
    return 0
  fi
  tar -czf - "${tar_args[@]}" 2>/dev/null \
    | age -R "${RECIPIENTS_FILE}" -o "${out}"
  chmod 600 "${out}"
  log "created ${out}"
}

rotate() {
  local files
  mapfile -t files < <(ls -1t "${DEST_DIR}"/*.tar.gz.age 2>/dev/null || true)
  if [[ "${#files[@]}" -le "${KEEP}" ]]; then
    log "rotation: ${#files[@]} archive(s) present, keeping all (limit ${KEEP})"
    return 0
  fi
  local idx=0
  for f in "${files[@]}"; do
    idx=$((idx + 1))
    if [[ "${idx}" -le "${KEEP}" ]]; then
      continue
    fi
    if ${DRY_RUN}; then
      log "would delete old archive: ${f}"
    else
      rm -f -- "${f}"
      log "deleted old archive: ${f}"
    fi
  done
}

main() {
  ensure_tools
  ensure_recipients
  ensure_dest
  build_archive
  rotate
}

main
