# OpenClaw — SPRINT-3.1-HANDOFF.md

> **Creado**: 2026-05-05 — cierre Sprint 3.1
> **VPS**: vmi3186391 (Contabo) — acceso root vía Cursor Remote-SSH
> **Versión OpenClaw**: 2026.5.2 (8b2a6e5)
> **Sprint activo**: sprint-006 (`ready-for-review`) — 2/2 items done

---

## 1. Estado del sistema al cierre

| Componente | Estado |
|-----------|--------|
| Gateway | `active (running)` desde 2026-05-03 16:06:57 |
| Anibal (main) | Activo — modelo `anthropic/claude-sonnet-4-6` + `claude-cli` oauth |
| Roy | Activo — modelos **solo openai-codex** (gpt-5.4 primary) |
| Cron `health-check-evening` | ✅ `ok` — última ejecución 18:16 CEST |
| Cron `nightly-bugs-first` | ✅ `ok` — última ejecución 16:45 CEST |
| Cron `daily-standup` | ✅ `ok` — última ejecución 15:03 CEST (gateway timeout en sessions_list) |
| Cron `sprint-pickup` | ✅ Creado — primer run lunes 2026-05-11 08:00 Santiago |
| Backup | 2 backups en disco (`openclaw-20260504-214500`, `openclaw-20260505-010001`) |
| Disco | 38G / 193G usados (20%) |

---

## 2. Trabajo ejecutado en Sprint 3.1 (2026-05-05)

### S-01 — Fix modelo Roy en sesiones aisladas ✅

**Problema:** Roy en sesiones cron intentaba usar `anthropic/claude-cli` como fallback → `No credentials found for profile "anthropic:claude-cli"` porque las sesiones aisladas no tienen `harness-auth/`.

**Fix aplicado en `openclaw.json`:**
```json
// agents.list donde id="roy" — override agregado:
"model": {
  "primary": "openai-codex/gpt-5.4",
  "fallbacks": [
    "openai-codex/gpt-5.5-medium",
    "openai-codex/gpt-5.3-codex"
  ]
}
```

**Verificado:** health-check corrió con `model=gpt-5.4`, status=ok.

---

### S-02 — Fix exec en sesiones aisladas de Roy ✅

**Problema original:** `exec host=sandbox requires a sandbox runtime` — Roy intentaba sandbox que no estaba disponible.
**Intento fallido:** cambiar `sandbox.mode` a `"non-main"` requería Docker (no instalado) → error en inicialización de sesión.
**Solución real:** `sandbox.mode` se mantuvo en `"off"`. Se configuraron pre-aprobaciones en `exec-approvals.json` para Roy con `ask=off, askFallback=deny`.

**Comandos nuevos en allowlist de Roy:**
```
/usr/bin/systemctl   /usr/bin/df      /usr/bin/grep
/usr/bin/wc          /usr/bin/find    /usr/bin/mkdir
/usr/bin/date        /usr/bin/node
```

**Comandos previos ya en allowlist:** `git`, `gh`, `ls`, `cat`, `echo`, `ls`, `printf`, `cp`, `sort`, `head`, `pwd`.

**Config de exec para Roy:** `ask=off`, `askFallback=deny`, `security=allowlist`.

---

### S-03 — nightly-bug-reports ✅

**Problema:** directorio no existía en workspace de Roy al momento del primer run nocturno.
**Estado:** directorio creado por Roy durante el standup del 05/05 09:02. Run manual del 05/05 16:45 confirma status=ok.
**Nota:** hay dos ubicaciones de reporte en el workspace:
- `workspaces/roy/scrum/nightly-bug-reports/` — creado por standup
- `workspaces/roy/nightly-bug-reports/` — creado por run manual (path incorrecto)

**Fix adicional:** prompt de `nightly-bugs-first` actualizado para referenciar explícitamente `/root/.openclaw/workspaces/roy/scrum/nightly-bug-reports/bugs-$(date +%Y-%m-%d).md`.

**Pendiente verificar:** en el próximo run nocturno (03:00 Santiago), comprobar que el reporte se escribe en `scrum/nightly-bug-reports/` y no en la raíz del workspace.

---

### S-04 — Workspace symlinks para Roy ✅

Roy solo puede leer/escribir dentro de `/root/.openclaw/workspaces/roy/`. Se crearon symlinks para que pueda acceder a archivos de scrum y estado del sistema:

```
workspaces/roy/scrum/sprint-state.json    → /root/.openclaw/scrum/sprint-state.json
workspaces/roy/scrum/product-backlog.json → /root/.openclaw/scrum/product-backlog.json
workspaces/roy/scrum/team-state.json      → /root/.openclaw/scrum/team-state.json
workspaces/roy/scrum/sprint-manager.js   → /root/.openclaw/scrum/sprint-manager.js
workspaces/roy/agents/main/agent/auth-state.json → /root/.openclaw/agents/main/agent/auth-state.json
workspaces/roy/agents/roy/agent/auth-state.json  → /root/.openclaw/agents/roy/agent/auth-state.json
workspaces/roy/logs/                      → /tmp/openclaw/
```

---

### G-16 — Decisión sprint-manager.js ✅

**Decisión tomada:** **Opción A** — `sprint-manager.js` es el motor de Scrum. Roy lo invoca vía `exec`.

**Fundamento:** el script ya tiene toda la lógica de gestión de estado (1316 líneas), GitHub sync de labels, validaciones, transiciones atómicas. Roy lee el contexto via `sprint-manager.js show` y ejecuta transiciones con `next-sprint`, `start-item`, `complete-item`, `close-review`.

**Implementado:**
- `/usr/bin/node` agregado al allowlist exec de Roy
- `sprint-manager.js` symlinkeado en `workspaces/roy/scrum/`

---

### Cron `sprint-pickup` — nuevo ✅

**ID:** `ac1263c5-8e58-4906-b980-b672c65396aa`
**Schedule:** lunes 08:00 America/Santiago (antes del daily-standup)
**Delivery:** `announce → telegram:6739292510` (explicit)

**Flujo del cron:**
1. `node sprint-manager.js show` — ver estado del sprint
2. Si status es `ready-for-review` o `closed`:
   - `import-github-issues` → importar issues nuevos
   - `next-sprint` → abrir nuevo sprint
   - `start-item <id>` → arrancar item top-priority
3. Si sprint `in-progress` → reportar estado sin cambiar nada
4. Reportar resumen vía Anibal a Telegram

---

### G-14 — Infrastructure QA ✅ (e2e pendiente)

**Creado workspace:** `/root/.openclaw/workspaces/qa-analyst/`

**Exec approvals para qa-analyst** (`ask=off, askFallback=deny, security=allowlist`):
```
git, gh, ls, cat, grep, find, pwd, echo, head, tail, wc, node, npm, python3
```

**Falta para validar el loop completo (requiere Felipe + Telegram):**
1. Roy recibe tarea real de Felipe
2. Roy despacha `backend-dev` → crea PR en feature branch
3. Roy despacha `qa-analyst` → revisa el PR
4. qa-analyst comenta findings en el PR
5. Roy notifica a backend-dev → itera
6. qa-analyst re-revisa → aprueba
7. Roy reporta a Felipe vía Anibal → Felipe hace merge

---

### Prompts de crons actualizados

| Cron | Cambio |
|------|--------|
| `health-check-evening` | Paths actualizados a workspace: `workspaces/roy/agents/main/agent/auth-state.json`, `workspaces/roy/logs/openclaw-$(date).log` |
| `daily-standup` | Agrega `node sprint-manager.js show` al inicio para contexto de sprint |
| `nightly-bugs-first` | Path de reporte corregido a `workspaces/roy/scrum/nightly-bug-reports/` |

---

## 3. Tabla de gaps — estado al 2026-05-05

| Gap | Descripción | Estado |
|-----|------------|--------|
| G-01 | Hidratar Roy | ✅ Cerrado Sprint 0 |
| G-02 | Worker `backend-dev` | ✅ Canónicos en disco (PR #2 merged) |
| G-03 | Worker `frontend-dev` | ✅ Canónicos en disco (PR #3 merged) |
| G-04 | Worker `qa-analyst` | ✅ Canónicos + workspace + exec approvals configurados |
| G-05 | Cron `daily-standup` 09:00 | ✅ Activo — status=ok (sub-G-25 resuelto Sprint 3.2) |
| G-06 | Cron `nightly-bugs-first` 03:00 | ✅ Activo — status=ok |
| G-07 | Cron `health-check-evening` 22:00 | ✅ Activo — status=ok |
| G-08 | Skill `agent-dispatch` | ⚠️ Sin evaluar — baja prioridad (Roy usa subagents directamente) |
| G-09 | Auditar OAuth + API keys | ✅ Cerrado Sprint 0 |
| G-10 | Backup automatizado diario | ✅ Activo — 2 backups en disco |
| G-11 | KPIs markdown + alert gateway | ✅ Activo — KPI generado 00:55, alert vía systemd OnFailure |
| G-12 | Validación e2e Sprint 0 (Roy solo) | ✅ Cerrado Sprint 0 |
| G-13 | Validación e2e Sprint 1 (Roy + worker) | ✅ Cerrado — PR #16 merged (feature/test-hello-world) |
| G-14 | Validación e2e Sprint 2 (QA loop) | ⚠️ Infrastructure lista — e2e real pendiente con tarea real de Felipe |
| G-14.b | Symlinks workers workspace (backend-dev/frontend-dev) | ✅ Symlinks creados Sprint 3.2: repo, worktrees, skills |
| G-15 | Especialistas efímeros probados | ❌ Pendiente (Sprint 3+) |
| G-16 | Decisión sprint-manager.js vs Roy | ✅ Opción A — sprint-manager.js como motor |
| G-17 | Política unblock + completedAt backlog | ❌ Pendiente (Sprint 3+) |
| G-18 | Branch protection en todos los agentes | ⚠️ Parcial — Roy ✅, workers pendiente de e2e real |
| G-19 | Auditar auth claude-sonnet-4-6 | ✅ Cerrado Sprint 0 |
| G-20 | Naming mismatch Anibal/Roy | ✅ Cerrado (D-013) |
| G-21 | Fallback chain vacía | ✅ Cerrado Sprint 0 |
| G-22 | TNS user openclaw.json | ⚠️ Diferible (root) |
| G-23 | Workspace mail-agent corrupto | ✅ Cerrado Sprint 1 |
| G-24 | gateway.auth.token cleartext | ✅ Cerrado Sprint 2.1 (→ .env) |
| G-24.b | botToken Telegram cleartext | ✅ Migrado a `${TELEGRAM_BOT_TOKEN}` en .env (Sprint 3.2) |
| G-24.c | Perplexity apiKey cleartext | ✅ Migrado a `${PERPLEXITY_API_KEY}` en .env (Sprint 3.2) |
| G-25 | 4 governance skills + clawflow | ✅ Cerrado Sprint 2.1 |
| sub-G-25 | sessions_list timeout en standup | ✅ Resuelto Sprint 3.2 — standup sin sessions_list, usa workspace paths |
| sprint-pickup | Cron autónomo backlog pickup | ✅ Creado — primer run lunes 11/05 |

**Conteo**: 22 cerrados ✅ / 4 pendientes ❌ o ⚠️ (Sprint 3.2 cerró: sub-G-25, G-14.b, G-24.b, G-24.c)

---

## 4. Gaps pendientes con detalle

### ✅ sub-G-25 — sessions_list timeout en standup (CERRADO Sprint 3.2)

**Diagnóstico realizado:** El timeout es hardcodeado en `call-HHsCuKDy.js:154` (10000ms). Configurable via `gateway.handshakeTimeoutMs` pero aplica solo a conexiones CLI→gateway, no a tool calls de agent sessions.
**Fix aplicado:**
- Reescritura del prompt standup: NO usa `sessions_list`, usa workspace paths + exec+cat para leer sprint-state.json, decisions-log de workers y `gh pr list`
- BOOT.md actualizado: §3 usa paths workspace para workers, §4 usa `skills/` (workspace), §5 elimina `sessions_list`
- Symlink `workspaces/roy/skills → /root/.openclaw/skills/` creado (Boot verifica skills sin salir del workspace)
- Symlinks `workspaces/roy/agents/backend-dev|frontend-dev|qa-analyst` creados
- `gateway.handshakeTimeoutMs: 30000` agregado a openclaw.json (mejora general para CLI→gateway)
**Resultado verificado:** standup status=ok, reporte generado y guardado en `scrum/daily-reports/daily-2026-05-05.md`

---

### ⚠️ G-14 — e2e QA loop real (infra completa, loop pendiente)

**Infrastructure:** ✅ Lista (qa-analyst workspace, exec approvals, subagents allowlist en Roy)
**Sprint 3.2 — symlinks worker workspaces:** ✅ Creados
- `workspaces/backend-dev/repo` → `/opt/tns-workbench/autonomous-workbench`
- `workspaces/backend-dev/worktrees` → `/opt/tns-workbench/autonomous-workbench/worktrees`
- `workspaces/backend-dev/skills` → `/root/.openclaw/skills`
- Idem para `frontend-dev` y `qa-analyst`

**Falta aún:** un PR real que qa-analyst revise. El flow completo requiere:
1. Felipe envía tarea real vía Telegram → Anibal → Roy
2. Roy despacha backend-dev con worktree
3. backend-dev implementa y crea PR en feature branch
4. Roy despacha qa-analyst con PR number
5. qa-analyst revisa, comenta en GitHub PR
6. Si issues → Roy notifica backend-dev → backend-dev itera
7. qa-analyst re-revisa → aprueba
8. Roy reporta a Felipe vía Anibal → Felipe hace merge

---

### ✅ G-24.b/c — Secrets migrados a .env (CERRADO Sprint 3.2)

**Fix aplicado:**
- `TELEGRAM_BOT_TOKEN` y `PERPLEXITY_API_KEY` agregados a `/root/.openclaw/.env`
- `openclaw.json` actualizado con referencias `${TELEGRAM_BOT_TOKEN}` y `${PERPLEXITY_API_KEY}`
- Verificado: gateway reiniciado, Telegram `@asistente_tns_bot` activo

---

### ❌ G-15 — Especialistas efímeros

`debugger` (skill instalada, agente efímero no probado) y `node-specialist` (no instalado). Baja prioridad hasta que haya e2e real funcionando.

---

### ❌ G-17 — Política de unblock + timestamps en backlog

Cuando un item se bloquea/desbloquea, `sprint-manager.js blockItem/unblockItem` no registra `startedAt/completedAt` de forma consistente. Baja prioridad.

---

---

## 4.bis. Cambios aplicados en Sprint 3.2 (2026-05-05)

### sub-G-25 — standup sin sessions_list ✅

| Archivo | Cambio |
|---------|--------|
| `openclaw.json` | `gateway.handshakeTimeoutMs: 30000` agregado |
| `cron/jobs.json` (standup 19aacccc) | Prompt reescrito: NO sessions_list, paths workspace explícitos |
| `workspaces/roy/BOOT.md` | §3 usa paths workspace para workers; §4 usa `skills/`; §5 elimina sessions_list |
| `agents/roy/agent/BOOT.md` | Idem (sincronizado) |
| `workspaces/roy/TOOLS.md` | Sección `tns-scrum-daily-standup` agregada |
| `agents/roy/agent/TOOLS.md` | Idem |
| `workspaces/roy/skills` | Symlink → `/root/.openclaw/skills/` |
| `workspaces/roy/agents/backend-dev|frontend-dev|qa-analyst` | Symlinks → agent dirs |
| `workspaces/roy/scrum/daily-reports/` | Directorio creado |

### G-14.b — Worker workspaces ✅

| Workspace | Symlinks creados |
|-----------|-----------------|
| `workspaces/backend-dev/` | `repo → autonomous-workbench`, `worktrees → .../worktrees`, `skills → skills` |
| `workspaces/frontend-dev/` | Idem |
| `workspaces/qa-analyst/` | Idem |

### G-24.b/c — Secrets a .env ✅

| Archivo | Cambio |
|---------|--------|
| `/root/.openclaw/.env` | `TELEGRAM_BOT_TOKEN` y `PERPLEXITY_API_KEY` agregados |
| `openclaw.json` | `botToken` y `apiKey` migrados a `${ENV_VAR}` |

**Backups Sprint 3.2:**
```
openclaw.json.bak.20260505-194254.pre-G25  — antes de sub-G-25
openclaw.json.bak.20260505-201510.pre-G24bc — antes de G-24.b/c
cron/jobs.json.bak.20260505-194254.pre-G25
```

---

## 5. Archivos modificados en esta sesión

| Archivo | Cambio |
|---------|--------|
| `/root/.openclaw/openclaw.json` | Roy model override (S-01); sandbox.mode intentado→revertido (S-02) |
| `/root/.openclaw/exec-approvals.json` | Roy: systemctl, df, grep, wc, find, mkdir, date, node; qa-analyst: sección nueva completa |
| `/root/.openclaw/workspaces/roy/scrum/*` | Symlinks: sprint-state.json, product-backlog.json, team-state.json, sprint-manager.js |
| `/root/.openclaw/workspaces/roy/agents/*/` | Symlinks: auth-state.json de Anibal y Roy |
| `/root/.openclaw/workspaces/roy/logs` | Symlink → /tmp/openclaw |
| `/root/.openclaw/workspaces/qa-analyst/` | Directorio creado (vacío — workspace del worker) |
| `/root/.openclaw/cron/jobs.json` | 4 crons: health-check, nightly-bugs, standup (prompts editados) + sprint-pickup (nuevo) |
| `/root/.openclaw/infra/generate-kpis.sh` | Sin cambios en esta sesión (fixes Sprint 3.0) |
| `/root/.openclaw/infra/backup-daily.sh` | Sin cambios (Sprint 3.0) |

**Backups de openclaw.json:**
```
openclaw.json.bak.20260505-HHMMSS.pre-S01-S02   — antes de S-01/S-02
```

---

## 6. Estado de crons al cierre

| ID (8 chars) | Nombre | Schedule | Último status | Próximo run |
|------|--------|----------|--------------|-------------|
| 2e061fd1 | health-check-evening | `0 22 * * *` Santiago | ✅ ok (18:16 CEST) | 22:00 Santiago |
| cc990687 | nightly-bugs-first | `0 3 * * *` Santiago | ✅ ok (16:45 CEST) | 03:00 Santiago |
| 19aacccc | daily-standup | `0 9 * * 1-5` Santiago | ✅ ok* | Lunes 09:00 Santiago |
| ac1263c5 | sprint-pickup | `0 8 * * 1` Santiago | idle (nuevo) | Lunes 11/05 08:00 Santiago |

*ok con limitación: sessions_list timeout → standup no consulta workers en tiempo real

---

## 7. Prompt de apertura para la siguiente sesión

Copiar literalmente como primer mensaje al abrir la próxima sesión con Claude Code:

---

**PROMPT DE APERTURA — SPRINT 3.3:**

```
Retomamos el desarrollo del sistema autónomo OpenClaw en VPS vmi3186391 (Contabo, root).

Lee y sigue al pie de la letra el documento /root/.openclaw/handoff/SPRINT-3.1-HANDOFF.md antes de responder nada. Ese documento contiene el estado exacto del sistema, todos los cambios aplicados hasta Sprint 3.2 y los gaps pendientes.

Contexto clave (estado al cierre Sprint 3.2, 2026-05-05):
- OpenClaw 2026.5.2 en /usr/lib/node_modules/openclaw/
- Gateway token en /root/.openclaw/.env → export OPENCLAW_GATEWAY_TOKEN=$(grep OPENCLAW_GATEWAY_TOKEN /root/.openclaw/.env | cut -d= -f2-)
- Sprint 006 en ready-for-review — 2/2 items done
- 4 crons activos: health-check-evening (22:00), nightly-bugs-first (03:00), daily-standup (09:00 L-V), sprint-pickup (08:00 lunes)
- Standup verificado: status=ok, sin sessions_list, reporte generado en scrum/daily-reports/

Cerrado en Sprint 3.2:
- sub-G-25: standup reescrito, BOOT.md actualizado, skills/agents symlinked en Roy workspace
- G-14.b: workers workspaces tienen repo/worktrees/skills symlinkeados
- G-24.b/c: TELEGRAM_BOT_TOKEN y PERPLEXITY_API_KEY migrados a .env

Gaps pendientes a cerrar (en este orden de prioridad):

1. G-14 e2e QA loop real: enviar una tarea real vía Telegram → Roy → backend-dev → PR → qa-analyst → feedback → merge. La infraestructura está lista; solo falta ejecutar el loop con una tarea real de Felipe.

2. Verificar primer run del cron sprint-pickup (lunes 11/05 08:00 Santiago). Debería importar issues de GitHub, abrir sprint-007 y arrancar el primer item.

3. G-15: especialistas efímeros — `debugger` (skill instalada, no probada), `node-specialist` (no instalado). Baja prioridad.

4. G-17: política unblock + timestamps en backlog (sprint-manager.js). Baja prioridad.

Antes de cualquier cambio: leer el archivo actual con Read, hacer backup .bak.YYYYMMDD-HHMMSS, validar con jq empty, reiniciar gateway.
```

---

## 8. Reglas inviolables (recordatorio)

1. **Regla #3 — 0 gasto por token**: solo OAuth. `usage.cost > 0` en `gpt-5.4` NO viola esta regla.
2. **Regla #5 — Branch protection by design**: ningún agente hace commit/push directo a `dev`/`main`/`master`.
3. **D-013 — Separación Anibal/Roy**: Roy habla a Felipe solo vía Anibal (salvo 5 breakglass en HEARTBEAT.md de Roy).
4. **Antes de cualquier cambio en archivos de config** (`openclaw.json`, `exec-approvals.json`, `cron/jobs.json`): (1) leer el archivo con Read, (2) backup `.bak.YYYYMMDD-HHMMSS.preX`, (3) validar con `jq empty`, (4) reiniciar gateway (`systemctl restart openclaw-gateway`). **Nota**: `exec-approvals.json` NO está sujeto a hot-reload — requiere restart obligatorio para aplicar cambios.
5. **Producción**: no tocar sin OK explícito de Felipe.

---

## 9. Comandos útiles de referencia rápida

```bash
# Cargar token del gateway
export OPENCLAW_GATEWAY_TOKEN=$(grep OPENCLAW_GATEWAY_TOKEN /root/.openclaw/.env | cut -d= -f2-)

# Estado del gateway
systemctl status openclaw-gateway --no-pager

# Listar crons
/usr/bin/node /usr/lib/node_modules/openclaw/openclaw.mjs cron list

# Correr cron manualmente (test)
/usr/bin/node /usr/lib/node_modules/openclaw/openclaw.mjs cron run <id> --timeout 15000

# Ver resultado del último run de un cron
python3 -c "import json; lines=open('/root/.openclaw/cron/runs/<id>.jsonl').readlines(); d=json.loads(lines[-1]); print(d['status'], d.get('summary','')[:300])"

# Sprint state
node /root/.openclaw/scrum/sprint-manager.js show

# Ver último KPI generado
cat /root/.openclaw/kpis/kpis-$(date +%Y-%m-%d).md

# Verificar allowlist exec de Roy
python3 -c "import json; d=json.load(open('/root/.openclaw/exec-approvals.json')); print([e['pattern'].split('/')[-1] for e in d['agents']['roy']['allowlist']])"

# Ver Roy model config
jq '.agents.list[] | select(.id=="roy") | .model' /root/.openclaw/openclaw.json
```

---

> **Creado**: 2026-05-05 — Claude Sonnet 4.6 — sesión Sprint 3.1
> **Basado en**: `SPRINT-3-HANDOFF.md` + `ROADMAP-PENDIENTE-SPRINT-3.md` + estado verificado en VPS al 2026-05-05 18:50 CEST
