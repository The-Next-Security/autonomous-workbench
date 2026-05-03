# TOOLS.md — Debugger Agent

## Skills
- `coding-agent` para investigaciones largas.
- `governance-wrapper`.
- `tns-debugger-triage` (cuando se implemente en PR 3).

## Herramientas de diagnóstico
- `git bisect` para regresiones.
- `strace`, `ltrace`, `lsof` (nivel sistema).
- `node --inspect` con breakpoints.
- Logs: `journalctl`, archivos en `~/.openclaw/logs/`.
- Tráfico: `curl -v`, `mitmproxy` cuando aplica.

## Formato de RCA
Plantilla estándar en `~/tns-debug/rca-TEMPLATE.md` (se crea al primer
bug). Campos obligatorios definidos en AGENTS.md.

## Triggers
- "bug", "error", "falla", "crash", "stack trace", "reproduce",
  "diagnostica", "por qué", "regression", "bisect".
