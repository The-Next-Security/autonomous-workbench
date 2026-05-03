#!/usr/bin/env bash
# credential-leak-scan.sh
#
# Scans recent log files for patterns that look like credentials
# accidentally leaking into logs. Reports hits; does not modify anything.
#
# Exit codes:
#   0 = no hits
#   1 = hits detected

set -euo pipefail

LOG_DIRS=(
  "${HOME}/.openclaw/logs"
  "/var/log"
)

PATTERNS=(
  'sk-[A-Za-z0-9]{20,}'
  'ghp_[A-Za-z0-9]{20,}'
  'gho_[A-Za-z0-9]{20,}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'pplx-[A-Za-z0-9]{20,}'
  'AIza[A-Za-z0-9_-]{20,}'
  '-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----'
  'xoxb-[0-9]+-[A-Za-z0-9]+'
  'xoxp-[0-9]+-[A-Za-z0-9]+'
)

hits=0

for dir in "${LOG_DIRS[@]}"; do
  [[ -d "${dir}" ]] || continue
  for pat in "${PATTERNS[@]}"; do
    while IFS= read -r match; do
      [[ -z "${match}" ]] && continue
      hits=$((hits + 1))
      echo "[credential-leak] hit in ${dir}: ${match}"
    done < <(grep -rEho "${pat}" "${dir}" 2>/dev/null | sort -u | head -5)
  done
done

if [[ "${hits}" -eq 0 ]]; then
  echo "[credential-leak] clean: no patterns detected in scanned logs"
  exit 0
fi

echo "[credential-leak] ${hits} potential credential pattern(s) found" >&2
echo "[credential-leak] review manually before any public upload or sharing" >&2
exit 1
