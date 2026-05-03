# Sub-agentes del equipo operativo

Detalle de los 10 workspaces que instala `infra/install-agents.sh`:
Aníbal (global, bajo `~/.openclaw/`) más 9 especialistas (bajo
`~/.openclaw/agents/<rol>/`). Complementa `docs/architecture.md` y
`docs/routing-matrix.md`.

## Aníbal

Global default de OpenClaw. Única interfaz humana. Coordina con Roy
(corredor) y con otros módulos como `mail-agent` y crons generales.
Templates versionados en `infra/anibal-templates/`.

Archivos en el runtime tras instalación:
- `~/.openclaw/SOUL.md`
- `~/.openclaw/IDENTITY.md`
- `~/.openclaw/USER.md`
- `~/.openclaw/AGENTS.md`
- `~/.openclaw/HEARTBEAT.md`

## Especialistas (9)

Estructura común para cada rol en `~/.openclaw/agents/<rol>/`:
- `SOUL.md` — identidad y tono.
- `IDENTITY.md` — posición jerárquica y colaboraciones.
- `USER.md` — contexto Felipe y org TNS heredado.
- `AGENTS.md` — rol, responsabilidades, artefactos, ceremonias,
  autoridad, relaciones, límites, KPIs.
- `HEARTBEAT.md` — checklist específico al rol.
- `BOOT.md` — protocolo de arranque de sesión.
- `TOOLS.md` — skills, herramientas y triggers.

### Matriz resumen de roles

| Rol | Workspace | Responsabilidad primaria | KPI clave |
|-----|-----------|--------------------------|-----------|
| product-owner | `~/.openclaw/agents/product-owner/` | Backlog, historias, aceptación | Items completados contra comprometidos |
| qa-analyst | `~/.openclaw/agents/qa-analyst/` | Tests, validación, regresiones | Defect escape rate < 10% |
| frontend-dev | `~/.openclaw/agents/frontend-dev/` | UI, estado cliente, tests UI | Lighthouse perf > 85 |
| backend-dev | `~/.openclaw/agents/backend-dev/` | APIs, BD, integraciones | p99 latency < 200 ms |
| ux-dev | `~/.openclaw/agents/ux-dev/` | Flows, wireframes, design system | 100% historias con diseño pre-impl |
| git-expert | `~/.openclaw/agents/git-expert/` | Branches, CI/CD, releases | 0 merges a main sin aprobación |
| docs-expert | `~/.openclaw/agents/docs-expert/` | README, specs, changelogs | 100% features con doc actualizado |
| node-specialist | `~/.openclaw/agents/node-specialist/` | Perf Node, tipado TS avanzado | 0 any sin justificación |
| debugger | `~/.openclaw/agents/debugger/` | RCA, stack traces, bisección | MTTR RCA < 2h priority high |

## Instalación y verificación

```
# Instalar o actualizar workspaces faltantes:
infra/install-agents.sh

# Reinstalar todos (sobreescribe):
infra/install-agents.sh --rebuild

# Reinstalar un solo rol:
infra/install-agents.sh --rebuild-role qa-analyst

# Verificar integridad:
infra/install-agents.sh --verify
```

El script es idempotente: correrlo dos veces sin flags no altera archivos
existentes. `--verify` retorna 0 si todos los workspaces están completos.

## Cron jobs instalados por el equipo

`infra/cron-jobs-1.0.0.json` define 4 jobs que `infra/install-crons.sh`
integra al `~/.openclaw/cron/jobs.json` preservando los jobs existentes
(Lobster, AI digest, etc.):

| Job | Schedule (Chile) | Target | Propósito |
|-----|------------------|--------|-----------|
| daily-standup | 09:00 diario | main | Roy consolida estado del equipo |
| nightly-backlog-processor | 03:00 diario | isolated | Policy Bugs First nocturna |
| health-check-evening | 22:00 diario | isolated | Check gateway, cron, cuota |
| weekly-report | Lunes 09:00 | main | Métricas semanales |

## Pass-through con sub-agentes

Los humanos pueden pedir a Aníbal que transmita literal a un especialista:

> "Aníbal, dile al Debugger que reproduzca el bug del issue #42."

Aníbal pasa la instrucción a Roy con marca `pass-through`, Roy la pasa al
Debugger sin reformular. La única excepción es si la instrucción viola
una regla inviolable, en cuyo caso Aníbal responde al humano con la
explicación.
