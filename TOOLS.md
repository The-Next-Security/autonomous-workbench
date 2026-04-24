# TOOLS.md — Skills frecuentes de Roy

Roy no tiene binarios propios. Este archivo documenta las skills y
herramientas del entorno que usa con mayor frecuencia, y los triggers que
las invocan.

## Skills Scrum que Roy coordina

Viven en `~/.openclaw/skills/` (repo `agents-files`). Roy las invoca
vía `/subagents spawn <rol>` o referencia directa cuando el trabajo es
puntual y no requiere sesión persistente.

- `scrum-master` — referencia de eventos Scrum, usada por Roy mismo.
- `product-owner` — triggers: "backlog", "prioriza", "user story".
- `qa-analyst` — triggers: "tests", "acceptance", "regresión".
- `frontend-developer` — triggers: "UI", "pantalla", "componente".
- `backend-developer` — triggers: "endpoint", "API", "BD".
- `ux-developer` — triggers: "flow", "wireframe", "diseño".
- `git-expert` — triggers: "rebase", "merge conflict", "CI".
- `documentation-expert` — triggers: "README", "CHANGELOG", "specs".
- `coding-agent` — delegación a Codex CLI para trabajo largo de código.

## Skills de soporte

- `governance-wrapper` — validación previa de acciones sensibles.
- `github-manager` — operaciones GitHub con protocolo HALT-on-approval.
- `giraffe-guard` — scan de supply chain en skills.
- `skill-threat-scanner` — scan de malware y prompt injection.
- `agent-audit-trail` — logging hash-chained de invocaciones.

## Binarios del sistema disponibles

- `git`, `gh` — control de versiones y GitHub CLI. Allow-always.
- `codex` — Codex CLI con OAuth ChatGPT Plus. Delegación larga.
- `openclaw` — CLI del runtime.
- `age` — cifrado simétrico para backups (se instala en PR 2).

## Rutas clave en el sistema

- Corredor: `/opt/tns-workbench/autonomous-workbench/`
- Worktrees: `/opt/tns-workbench/autonomous-workbench/worktrees/`
- Runtime (no tocar): `/root/.openclaw/`
- Motor Scrum: `/root/.openclaw/scrum/` (solo lectura desde el corredor)
- Skills: `/root/.openclaw/skills/` (solo lectura desde el corredor)

## Canales

- Telegram: chatID `6739292510` (Felipe), grupo `-1003805408477` con
  mención requerida.
- GitHub org: `The-Next-Security`.

## Modelo LLM

- Primario: `openai-codex/gpt-5.4` vía OAuth ChatGPT Plus.
- Fallback: `openai-codex/gpt-5.3-codex`.
- Prohibido: cualquier API key.
