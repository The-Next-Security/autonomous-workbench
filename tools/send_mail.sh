#!/bin/bash
# send_mail.sh — script canónico de envío para OpenClaw
# Uso: send_mail.sh <to> <subject> <body> [archivo1] [archivo2] ... [archivoN]
# Los archivos deben existir antes de llamar este script.

set -euo pipefail

TO="${1:-}"
SUBJECT="${2:-}"
BODY="${3:-}"
shift 3 || true
ATTACHMENTS=("$@")

if [[ -z "$TO" || -z "$SUBJECT" || -z "$BODY" ]]; then
  echo "ERROR: Uso: send_mail.sh <to> <subject> <body> [archivos...]" >&2
  exit 1
fi

# Validar adjuntos antes de construir el mensaje
for f in "${ATTACHMENTS[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Adjunto no existe: $f" >&2
    exit 1
  fi
  if [[ ! -s "$f" ]]; then
    echo "ERROR: Adjunto vacío: $f" >&2
    exit 1
  fi
done

# Construir mensaje MML
MSG="From: TNS Bot <anibal.tns@gmail.com>
To: $TO
Subject: $SUBJECT
"

if [[ ${#ATTACHMENTS[@]} -eq 0 ]]; then
  # Sin adjuntos — texto plano directo
  MSG+="
$BODY"
else
  # Con adjuntos — multipart mixed
  MSG+="
<#multipart type=mixed>
<#part type=text/plain>
$BODY"
  for f in "${ATTACHMENTS[@]}"; do
    FNAME=$(basename "$f")
    MSG+="
<#part filename=$f name=$FNAME><#/part>"
  done
  MSG+="
<#/multipart>"
fi

# Enviar
echo "$MSG" | himalaya template send --account tns
echo "OK: correo enviado a $TO"
