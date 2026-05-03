# Arquitectura del sistema autónomo

## Jerarquía de agentes

```
Humanos (Felipe Vásquez + organización TNS)
    |
    | entrada única por Telegram, email o PR/issue GitHub
    |
  ANÍBAL
  - Agente global default de OpenClaw
  - Vive en /root/.openclaw/ (agente "main")
  - Única interfaz humana
  - Coordina trabajo general y de programación
    |
    | delegación explícita para trabajo de código
    |
  ROY (alias SCRUM MASTER)
  - Sub-agente del corredor /opt/tns-workbench/autonomous-workbench/
  - Servant-leader del equipo autónomo de desarrollo
  - "Roy" y "Scrum Master" son nombres intercambiables
    |
    | spawn de especialistas según la tarea
    |
  9 ESPECIALISTAS (workspaces en ~/.openclaw/agents/<rol>/)
  - product-owner       Backlog, historias, prioridades
  - qa-analyst          Tests, validación, acceptance
  - frontend-dev        UI, estado cliente, responsive
  - backend-dev         APIs, servicios, BD, integraciones
  - ux-dev              Wireframes, flows, design system
  - git-expert          Branching, merges, CI/CD
  - docs-expert         READMEs, specs, changelogs
  - node-specialist     Performance Node, tipado TS avanzado (nuevo)
  - debugger            RCA, stack traces, reproducción (nuevo)
```

## Principio de separación

- **Runtime (no modificar desde el corredor):** `/root/.openclaw/`.
  Contiene Aníbal, skills, motor Scrum, cron, memoria, credenciales. Se
  administra manualmente por Felipe o se actualiza vía scripts idempotentes
  de `infra/`.

- **Corredor (espacio de trabajo):** `/opt/tns-workbench/autonomous-workbench/`.
  Aquí vive Roy. Todo el código que el sistema escribe ocurre en este
  corredor o en sus worktrees. Es versionado en Git.

- **Workspaces de especialistas:** `~/.openclaw/agents/<rol>/`.
  Cada uno tiene su propio `SOUL.md`, `IDENTITY.md`, `USER.md`,
  `AGENTS.md`, `HEARTBEAT.md`, `BOOT.md`, `TOOLS.md`. Son gestionados por
  el script idempotente `infra/install-agents.sh` (implementado en PR 1.1)
  a partir de los templates versionados en `infra/agent-templates/`.

## Comunicación

### Humano hacia el sistema
Los humanos escriben a Telegram o comentan en PRs/issues. Aníbal recibe
siempre. Los humanos no interactúan directamente con Roy ni con los
especialistas.

### Pass-through
Cualquier humano puede pedir a Aníbal que transmita literal a Roy o a un
especialista: "Aníbal, dile a Roy que X" o "transmite al Debugger que Y".
Aníbal traslada sin reformular, salvo que la instrucción viole una regla
inviolable (en cuyo caso responde al humano con la explicación).

### Aníbal hacia Roy
Aníbal delega a Roy con formato estructurado:
- Objetivo concreto.
- Criterio de éxito verificable.
- Contexto relevante (issues, PRs, archivos).
- Si el humano pidió pass-through, la instrucción textual.

Roy responde con: qué hizo, evidencia (URL de PR, hash de commit), estado
final.

### Roy hacia especialistas
Roy spawnea especialistas con `/subagents spawn <rol>` o por referencia
directa. Pasa contexto completo de la tarea y recibe output verificable.
Detalle de ruteo en `docs/routing-matrix.md`.

## Flujo típico de una tarea de programación

1. Felipe escribe a Telegram: "crea archivo X con contenido Y".
2. Aníbal recibe y determina que es trabajo de código.
3. Aníbal delega a Roy con el objetivo y criterio de éxito.
4. Roy evalúa la matriz de ruteo.
5. Roy crea worktree en `/opt/tns-workbench/autonomous-workbench/worktrees/`.
6. Roy crea branch `feature/<slug>`.
7. Roy (o un especialista spawneado) ejecuta el cambio.
8. Roy hace commit con mensaje claro, push, y abre PR a `dev`.
9. Roy reporta a Aníbal con la URL del PR.
10. Aníbal responde a Felipe con la URL y el estado.

## Repositorios del sistema

- `autonomous-workbench` — este corredor. Roy + documentación principal.
- `scrum-files` — motor Scrum (`sprint-manager.js`, `product-backlog.json`).
- `agents-files` — skills y governance.

Política de ramas uniforme: `main` protegida, `dev` integración,
`feature/*` y `fix/*` trabajo. Merge no fast-forward.
