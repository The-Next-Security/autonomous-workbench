#!/usr/bin/env bash
# unset-api-keys.sh
#
# Idempotently adds `unset OPENAI_API_KEY` (and peers) to ~/.bashrc so
# every new shell starts without API keys. Safe to run multiple times.
#
# Flags:
#   --dry-run   Show what would be added without writing.

set -euo pipefail

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

BLOCK_BEGIN="# >>> tns autonomous system: unset API keys (1.0.0) >>>"
BLOCK_END="# <<< tns autonomous system: unset API keys (1.0.0) <<<"
BASHRC="${HOME}/.bashrc"

block=$(cat <<EOF
${BLOCK_BEGIN}
unset OPENAI_API_KEY
unset ANTHROPIC_API_KEY
unset OPENROUTER_API_KEY
${BLOCK_END}
EOF
)

if grep -qF "${BLOCK_BEGIN}" "${BASHRC}" 2>/dev/null; then
  echo "[unset-api-keys] block already present in ${BASHRC}, nothing to do"
  exit 0
fi

if ${DRY_RUN}; then
  echo "[unset-api-keys] would append to ${BASHRC}:"
  echo "${block}"
  exit 0
fi

printf '\n%s\n' "${block}" >> "${BASHRC}"
echo "[unset-api-keys] block appended to ${BASHRC}"
echo "[unset-api-keys] source it now with: source ~/.bashrc"
