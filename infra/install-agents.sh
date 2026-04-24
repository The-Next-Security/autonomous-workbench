#!/usr/bin/env bash
# install-agents.sh
#
# Idempotent installer for the autonomous team: creates or verifies the
# workspaces of Aníbal (global default) and the 9 specialists under the
# OpenClaw runtime (~/.openclaw/).
#
# Usage:
#   install-agents.sh [--dry-run] [--verify] [--rebuild] [--rebuild-role <rol>]
#
# Flags:
#   --dry-run              Show actions without touching the filesystem.
#   --verify               Check that all workspaces exist with the expected
#                          files. Exit non-zero if any is missing or stale.
#   --rebuild              Rebuild all workspaces from templates (overwrite).
#   --rebuild-role <rol>   Rebuild only the given role.
#
# Default behavior (no flags): install missing workspaces, keep existing
# files untouched. Safe to run repeatedly.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANIBAL_TEMPLATES="${REPO_ROOT}/infra/anibal-templates"
AGENT_TEMPLATES="${REPO_ROOT}/infra/agent-templates"
RUNTIME_ROOT="${HOME}/.openclaw"
ANIBAL_DIR="${RUNTIME_ROOT}"
AGENTS_ROOT="${RUNTIME_ROOT}/agents"

SPECIALISTS=(
  "product-owner"
  "qa-analyst"
  "frontend-dev"
  "backend-dev"
  "ux-dev"
  "git-expert"
  "docs-expert"
  "node-specialist"
  "debugger"
)

ANIBAL_FILES=(SOUL.md IDENTITY.md USER.md AGENTS.md HEARTBEAT.md)
SPECIALIST_FILES=(SOUL.md IDENTITY.md USER.md AGENTS.md HEARTBEAT.md BOOT.md TOOLS.md)

DRY_RUN=false
VERIFY=false
REBUILD=false
REBUILD_ROLE=""

log() { printf '[install-agents] %s\n' "$*"; }
err() { printf '[install-agents] ERROR: %s\n' "$*" >&2; }

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=true; shift ;;
      --verify) VERIFY=true; shift ;;
      --rebuild) REBUILD=true; shift ;;
      --rebuild-role)
        REBUILD_ROLE="${2:-}"
        if [[ -z "${REBUILD_ROLE}" ]]; then
          err "--rebuild-role requires a role name"; exit 2
        fi
        shift 2 ;;
      -h|--help)
        sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
        exit 0 ;;
      *) err "unknown flag: $1"; exit 2 ;;
    esac
  done
}

check_prereqs() {
  if [[ ! -d "${ANIBAL_TEMPLATES}" ]]; then
    err "Aníbal templates not found at ${ANIBAL_TEMPLATES}"
    err "This branch requires PR 1.0 merged to dev, or feature/1.0.0-governance checked out."
    exit 3
  fi
  if [[ ! -d "${AGENT_TEMPLATES}" ]]; then
    err "Specialist templates not found at ${AGENT_TEMPLATES}"
    exit 3
  fi
  for rol in "${SPECIALISTS[@]}"; do
    if [[ ! -d "${AGENT_TEMPLATES}/${rol}" ]]; then
      err "missing template directory for role: ${rol}"
      exit 3
    fi
  done
}

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [[ -f "${dst}" && "${REBUILD}" != true ]]; then
    return 0
  fi
  if ${DRY_RUN}; then
    log "would copy ${src} -> ${dst}"
  else
    cp "${src}" "${dst}"
    log "copied ${src##*/} -> ${dst}"
  fi
}

install_anibal() {
  if ${DRY_RUN}; then
    log "would ensure dir ${ANIBAL_DIR}"
  else
    mkdir -p "${ANIBAL_DIR}"
  fi
  for f in "${ANIBAL_FILES[@]}"; do
    copy_if_missing "${ANIBAL_TEMPLATES}/${f}" "${ANIBAL_DIR}/${f}"
  done
}

install_specialist() {
  local rol="$1"
  local dst_dir="${AGENTS_ROOT}/${rol}"
  local src_dir="${AGENT_TEMPLATES}/${rol}"

  if ${DRY_RUN}; then
    log "would ensure dir ${dst_dir}"
  else
    mkdir -p "${dst_dir}"
  fi

  for f in "${SPECIALIST_FILES[@]}"; do
    if [[ ! -f "${src_dir}/${f}" ]]; then
      err "missing template file: ${src_dir}/${f}"
      return 1
    fi
    copy_if_missing "${src_dir}/${f}" "${dst_dir}/${f}"
  done
}

verify_anibal() {
  local ok=true
  if [[ ! -d "${ANIBAL_DIR}" ]]; then
    err "Aníbal workspace missing: ${ANIBAL_DIR}"
    return 1
  fi
  for f in "${ANIBAL_FILES[@]}"; do
    if [[ ! -f "${ANIBAL_DIR}/${f}" ]]; then
      err "Aníbal file missing: ${ANIBAL_DIR}/${f}"
      ok=false
    fi
  done
  ${ok}
}

verify_specialist() {
  local rol="$1"
  local dir="${AGENTS_ROOT}/${rol}"
  local ok=true
  if [[ ! -d "${dir}" ]]; then
    err "workspace missing: ${dir}"
    return 1
  fi
  for f in "${SPECIALIST_FILES[@]}"; do
    if [[ ! -f "${dir}/${f}" ]]; then
      err "file missing: ${dir}/${f}"
      ok=false
    fi
  done
  ${ok}
}

do_verify() {
  local all_ok=true
  if ! verify_anibal; then all_ok=false; fi
  for rol in "${SPECIALISTS[@]}"; do
    if ! verify_specialist "${rol}"; then all_ok=false; fi
  done
  if ${all_ok}; then
    log "verify OK: all workspaces present and complete"
    return 0
  else
    err "verify FAILED"
    return 1
  fi
}

do_install() {
  if [[ -n "${REBUILD_ROLE}" ]]; then
    local found=false
    for rol in "${SPECIALISTS[@]}"; do
      if [[ "${rol}" == "${REBUILD_ROLE}" ]]; then found=true; break; fi
    done
    if [[ "${REBUILD_ROLE}" == "anibal" ]]; then
      REBUILD=true
      install_anibal
      return 0
    elif ${found}; then
      REBUILD=true
      install_specialist "${REBUILD_ROLE}"
      return 0
    else
      err "unknown role: ${REBUILD_ROLE}"
      err "valid roles: anibal ${SPECIALISTS[*]}"
      return 2
    fi
  fi

  install_anibal
  for rol in "${SPECIALISTS[@]}"; do
    install_specialist "${rol}"
  done
  log "install complete (dry-run=${DRY_RUN}, rebuild=${REBUILD})"
}

main() {
  parse_args "$@"
  check_prereqs

  if ${VERIFY}; then
    do_verify
    exit $?
  fi

  do_install
}

main "$@"
