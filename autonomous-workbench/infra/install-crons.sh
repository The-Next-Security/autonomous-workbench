#!/usr/bin/env bash
# install-crons.sh
#
# Idempotent merge of infra/cron-jobs-1.0.0.json into
# ~/.openclaw/cron/jobs.json without touching pre-existing jobs.
#
# Usage:
#   install-crons.sh [--dry-run] [--verify]
#
# Behavior:
#   - Reads the 4 jobs defined in cron-jobs-1.0.0.json.
#   - For each job, checks if a job with the same name exists in
#     ~/.openclaw/cron/jobs.json. If not, inserts it with a new UUID
#     and current timestamps. If yes, leaves it untouched.
#   - --dry-run: show actions without writing.
#   - --verify: exit 0 if all 4 jobs are present, non-zero otherwise.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_JSON="${REPO_ROOT}/infra/cron-jobs-1.0.0.json"
TARGET_JSON="${HOME}/.openclaw/cron/jobs.json"

DRY_RUN=false
VERIFY=false

log() { printf '[install-crons] %s\n' "$*"; }
err() { printf '[install-crons] ERROR: %s\n' "$*" >&2; }

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=true; shift ;;
      --verify) VERIFY=true; shift ;;
      -h|--help)
        sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
        exit 0 ;;
      *) err "unknown flag: $1"; exit 2 ;;
    esac
  done
}

check_prereqs() {
  if ! command -v jq >/dev/null 2>&1; then
    err "jq is required"; exit 3
  fi
  if [[ ! -f "${SOURCE_JSON}" ]]; then
    err "source not found: ${SOURCE_JSON}"; exit 3
  fi
  if [[ ! -f "${TARGET_JSON}" ]]; then
    err "target not found: ${TARGET_JSON}"
    err "This script expects an existing jobs.json (even empty)."
    exit 3
  fi
}

verify_target() {
  local missing=0
  mapfile -t names < <(jq -r '.jobs[].name' "${SOURCE_JSON}")
  for name in "${names[@]}"; do
    local found
    found=$(jq --arg n "${name}" '[.jobs[] | select(.name == $n)] | length' "${TARGET_JSON}")
    if [[ "${found}" -eq 0 ]]; then
      err "missing job: ${name}"
      missing=$((missing + 1))
    fi
  done
  if [[ "${missing}" -eq 0 ]]; then
    log "verify OK: all jobs from 1.0.0 are present"
    return 0
  fi
  err "verify FAILED: ${missing} job(s) missing"
  return 1
}

merge_jobs() {
  local target_copy
  target_copy="$(mktemp)"
  cp "${TARGET_JSON}" "${target_copy}"

  local now_ms
  now_ms=$(($(date +%s) * 1000))
  local inserted=0
  local skipped=0

  mapfile -t names < <(jq -r '.jobs[].name' "${SOURCE_JSON}")
  for name in "${names[@]}"; do
    local found
    found=$(jq --arg n "${name}" '[.jobs[] | select(.name == $n)] | length' "${target_copy}")
    if [[ "${found}" -gt 0 ]]; then
      log "skip (already present): ${name}"
      skipped=$((skipped + 1))
      continue
    fi

    local job_json uuid new_job
    job_json=$(jq --arg n "${name}" '.jobs[] | select(.name == $n)' "${SOURCE_JSON}")
    uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen)

    new_job=$(jq -n \
      --arg id "${uuid}" \
      --argjson ms "${now_ms}" \
      --argjson body "${job_json}" \
      '$body + {id: $id, createdAtMs: $ms, updatedAtMs: $ms, state: {nextRunAtMs: 0}}')

    if ${DRY_RUN}; then
      log "would insert: ${name} (id ${uuid})"
    else
      jq --argjson j "${new_job}" '.jobs += [$j]' "${target_copy}" > "${target_copy}.new"
      mv "${target_copy}.new" "${target_copy}"
      log "inserted: ${name} (id ${uuid})"
      inserted=$((inserted + 1))
    fi
  done

  if ! ${DRY_RUN}; then
    local backup="${TARGET_JSON}.bak.$(date +%Y%m%d-%H%M%S).pre-1.0.0-crons"
    cp "${TARGET_JSON}" "${backup}"
    log "backup: ${backup}"
    mv "${target_copy}" "${TARGET_JSON}"
  fi

  log "merge complete (inserted=${inserted}, skipped=${skipped}, dry_run=${DRY_RUN})"
}

main() {
  parse_args "$@"
  check_prereqs

  if ${VERIFY}; then
    verify_target
    exit $?
  fi

  merge_jobs
}

main "$@"
