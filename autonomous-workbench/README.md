# autonomous-workbench

Corredor de ejecución del sistema autónomo de programación de TNS
sobre OpenClaw. Aquí vive Roy (Scrum Master) y desde aquí se ejecuta
todo el trabajo de código autónomo. Este repositorio es uno de los
tres que forman la base del sistema.

## Qué es este repositorio

`autonomous-workbench` es:

- **La casa de Roy**: los archivos markdown de la raíz
  (`SOUL.md`, `IDENTITY.md`, `USER.md`, `AGENTS.md`, `HEARTBEAT.md`,
  `BOOT.md`, `TOOLS.md`) definen la personalidad, reglas y protocolo
  operativo del agente que coordina al equipo.
- **El espacio de trabajo autónomo**: todo código autónomo ocurre
  dentro de este corredor y sus worktrees en `worktrees/`. Ningún
  agente del sistema puede modificar `/root/.openclaw/` desde aquí.
- **La documentación viva del sistema**: `docs/architecture.md`,
  `docs/policies.md`, `docs/routing-matrix.md`, `docs/subagents.md`,
  `docs/security.md`, `docs/backup-and-restore.md`,
  `docs/observability.md`, `docs/webhooks.md` y `docs/KPIS.md`
  conforman la referencia de diseño y operación.
- **Los scripts de infra**: en `infra/` viven los templates de
  agentes, los instaladores idempotentes, los scripts de seguridad,
  backup, alertas, observabilidad y el receptor seguro de webhooks
  GitHub.

## Los tres repos base del sistema

| Repo | Rol |
|------|-----|
| `autonomous-workbench` (este repo) | Corredor, Roy, docs principales, infra |
| `scrum-files` | Motor Scrum (`sprint-manager.js`, backlog, estado) |
| `agents-files` | Skills de los 9 roles especialistas y skills de soporte |

El sistema mantiene su estado interno en `~/.openclaw/` sincronizado
con estos tres repos vía GitHub.

## Arquitectura rápida

```
Humanos (Felipe + aprobadores autorizados de TNS)
    -> Aníbal (agente global, en /root/.openclaw/)
        -> Roy = Scrum Master (en este corredor)
            -> 9 especialistas (en ~/.openclaw/agents/<rol>/)
```

Los humanos hablan siempre con Aníbal (Telegram, PRs, issues).
Aníbal delega trabajo de programación a Roy. Roy coordina al equipo
Scrum de 9 especialistas (Product Owner, QA Analyst, Frontend Dev,
Backend Dev, UX Dev, Git Expert, Docs Expert, Node/TS Specialist,
Debugger) siguiendo el framework Scrum estándar.

Detalle completo: `docs/architecture.md`.

## Política de ramas

- `main` protegida. No commits directos, no force push. Merges solo
  en release con aprobación humana.
- `dev` rama de integración. Todos los PRs apuntan a `dev`.
- `feature/*` y `fix/*` ramas de trabajo. Para 1.0.0:
  `feature/1.0.0-<slug>`.
- Merge strategy: no fast-forward (`--no-ff`).

Aprobadores autorizados de merges a `main`: `felipecleverox`,
`Bufigol`, `TNSTRACK`, `andresTNS`. Estos usuarios también pueden ser
reviewers de PRs.

## Reglas de trazabilidad (OpenClaw Autonomous Rules)

1. **Trazabilidad obligatoria** — toda acción autónoma que modifique
   estado en GitHub deja comentario explicativo.
2. **Prohibición de acciones silenciosas** — acción sin comentario se
   considera incompleta.
3. **Formato obligatorio de comentario** en PRs e issues cuando
   aplica:

   ```markdown
   ## Acción — OpenClaw

   ### Qué se hizo
   ...

   ### Por qué
   ...

   ### Regla aplicada
   ...
   ```

4. **Rama de integración** — todos los PRs autónomos apuntan a `dev`;
   `main` no es base válida fuera de release.

Detalle de políticas duras (Bugs First, One Worktree One Agent,
Ralph Wiggum): `docs/policies.md`.

## Cómo está organizado el repo

```
autonomous-workbench/
├── SOUL.md IDENTITY.md USER.md AGENTS.md HEARTBEAT.md BOOT.md TOOLS.md
│       Archivos de hidratación de Roy (agente default del corredor)
├── README.md                          (este archivo)
├── AUTONOMOUS-RULES.md                Reglas de autonomía legibles por humanos
├── TEST_AUTONOMY.md                   Marcador histórico de validación e2e
├── docs/
│   ├── architecture.md                Diagrama jerárquico y patrones
│   ├── policies.md                    Bugs First, One Worktree, Ralph Wiggum
│   ├── routing-matrix.md              Cómo Roy decide a quién delegar
│   ├── subagents.md                   Matriz de 10 workspaces y KPIs
│   ├── security.md                    Modelo de amenazas y controles
│   ├── backup-and-restore.md          Procedimiento y gate
│   ├── observability.md               Health checks, KPIs, alertas
│   ├── webhooks.md                    Receptor seguro de eventos GitHub
│   ├── KPIS.md                        Snapshot (auto-generado)
│   ├── e2e-validation.md              Notas de validación e2e
│   └── validation.txt                 Marcador de readiness inicial
├── policies/
│   └── WORKBENCH-GOVERNANCE.md        Policy del corredor
├── infra/
│   ├── install-agents.sh              Instalador idempotente de workspaces
│   ├── install-crons.sh               Instalador idempotente de cron
│   ├── cron-jobs-1.0.0.json           4 jobs del equipo
│   ├── anibal-templates/              Templates para el workspace de Aníbal
│   ├── agent-templates/<rol>/         Templates para los 9 especialistas
│   ├── lib/telegram-notify.sh         Helper para alertas salientes
│   ├── security/                      oauth-audit, unset-api-keys, leak-scan
│   ├── backup/                        backup y restore cifrados con age
│   ├── alerts/                        gateway-watchdog, oauth-status, quota
│   ├── observability/                 health-check, compute-kpis
│   └── webhooks/                      github-handler + módulos + systemd unit
├── scratch/                           Área transitoria (no versionada)
└── worktrees/                         Worktrees aisladas por tarea
```

## Cómo contribuir

Este repo está abierto para que miembros de la organización TNS lean
y comenten. Contribuciones humanas siguen la política de ramas:

1. Crear branch `feature/<slug>` desde `dev`.
2. Hacer cambios con commits de mensaje claro.
3. Abrir PR con base `dev`.
4. Asignar revisor de la lista de aprobadores.
5. Tras aprobación, merge no fast-forward.

Para discusiones más generales (diseño, prioridades, aclaraciones),
usar los issues del repo o comentar en el issue paraguas vigente (en
1.0.0, issue #13).

Roy (el agente) es colaborador de este repo como el resto del equipo
y sigue exactamente el mismo flujo.

## Estado actual y roadmap

Estado: 0.1.0. Camino a 1.0.0 documentado en el issue paraguas #13 y
en el plan de 5 PRs (gobernanza, equipo, hardening, webhooks, skills
TNS).

Roadmap posterior (1.x): extender el sistema para trabajar
autónomamente sobre repos adicionales de TNS y de clientes con
autorización explícita; skills TNS-específicas adicionales;
observabilidad avanzada; automatización completa de respuesta a
eventos GitHub.

## Modelo LLM

Primario: `openai-codex/gpt-5.4` vía OAuth ChatGPT Plus.
Prohibido `OPENAI_API_KEY`. Detalles en `docs/security.md`.

## Contacto operativo

- Canal principal: Telegram `@asistente_tns_bot`, chatID `6739292510`
  (Felipe).
- GitHub: issues y PRs de este repo y de `scrum-files`/`agents-files`.
- Email administrativo: `felipe@thenextsecurity.cl`.
