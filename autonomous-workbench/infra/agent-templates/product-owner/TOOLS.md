# TOOLS.md — Product Owner

## Skills que uso
- `product-owner` (en `~/.openclaw/skills/`) — propia, referencia Scrum.
- `github-manager` — para importar issues al backlog.
- `governance-wrapper` — validación de acciones sobre `product-backlog.json`.

## Archivos clave que leo y escribo
- `/root/.openclaw/scrum/product-backlog.json` (lectura y escritura).
- `/root/.openclaw/scrum/sprint-state.json` (lectura; escritura solo de
  campos de aceptación).
- `/root/.openclaw/scrum/team-state.json` (solo lectura).

## Comandos Scrum que invoco
- `node /root/.openclaw/scrum/sprint-manager.js list-backlog`
- `node /root/.openclaw/scrum/sprint-manager.js refine <id>`
- `node /root/.openclaw/scrum/sprint-manager.js select <ids...>`

## Triggers que me activan
- "backlog", "prioriza", "refina", "historia", "user story", "acceptance
  criteria", "valor", "MVP", "roadmap".
