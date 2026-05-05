# SPRINT-3-HANDOFF.md

> **Propósito**: punto de entrada limpio para la próxima sesión.
> Sprint 3 en curso. Este documento refleja el estado al cierre de la sesión 2026-05-04.
>
> **Historial previo**:
> - `SPRINT-2.1-HANDOFF.md` — estado completo al inicio y cierre del Sprint 2.1.
> - `SPRINT-2-HANDOFF.md` — Sprint 2.
> - `SPRINT-0-HANDOFF.md` — historial §1–16 desde el deploy inicial (2026-04-27).
>
> **Audiencia**: agente IA en la próxima sesión + Felipe.

---

## 1. Estado del sistema (snapshot 2026-05-04 — sesión Sprint 3 parcial)

| Campo | Valor |
|-------|-------|
| VPS | `vmi3186391`, `207.180.249.180`, root via Cursor Remote-SSH |
| OpenClaw versión | **2026.5.2** |
| Gateway | `openclaw-gateway.service` — activo, PID **507113** |
| Plugins cargados | anthropic, browser, telegram (3) |
| Modelo primario | `anthropic/claude-sonnet-4-6` vía `claude-cli` OAuth |
| Fallbacks | `openai-codex/gpt-5.4` → `openai-codex/gpt-5.3-codex` (OAuth ChatGPT Plus) |
| Workspace multi-root | `/root/.openclaw/openclaw-vps.code-workspace` |

> ⚠️ El PID del gateway cambia en cada restart. Verificar siempre con:
> `systemctl status openclaw-gateway --no-pager | grep "Main PID"`

---

## 2. Configuración activa en `openclaw.json`

| Parámetro | Valor |
|-----------|-------|
| `agents.defaults.timeoutSeconds` | `300` |
| `agents.defaults.bootstrapMaxChars` | `14000` |
| `agents.defaults.models[sonnet-4-6].params.thinking` | `"none"` |
| `agents.list[main].subagents.allowAgents` | `["main","roy","mail-agent"]` |
| `agents.list[roy].subagents.allowAgents` | `["backend-dev","frontend-dev"]` ← nuevo Sprint 3 |
| `gateway.auth.token` | `"${OPENCLAW_GATEWAY_TOKEN}"` ← ya no es cleartext |

**Exec policy de Roy**: `security: allowlist` — solo `/usr/bin/git`, `cat`, `echo`, `pwd`.

**Secretos en disco** (fuera de `openclaw.json`):
- `gateway.auth.token` → `/root/.openclaw/.env` (`OPENCLAW_GATEWAY_TOKEN`, permisos 600)
- `channels.telegram.botToken` → **aún en cleartext** en `openclaw.json` (deuda técnica G-24.b)
- `plugins.perplexity.apiKey` → **aún en cleartext** en `openclaw.json` (deuda técnica G-24.c)

---

## 3. Agentes registrados

| ID | Nombre | Capa | AgentDir | Canónicos |
|----|--------|------|----------|-----------|
| `main` | Anibal | 0 — cara pública Telegram | `/root/.openclaw/agents/main/agent` | ✅ |
| `roy` | Roy | 1 — Scrum Master | `/root/.openclaw/agents/roy/agent` | ✅ |
| `mail-agent` | mail-agent | n/a — inactivo | `/root/.openclaw/agents/mail-agent/agent` ⚠️ dir no existe | ❌ |
| `backend-dev` | backend-dev | 2 — Worker Backend | `/root/.openclaw/agents/backend-dev/agent` | ✅ nuevo Sprint 3 |
| `frontend-dev` | frontend-dev | 2 — Worker Frontend | `/root/.openclaw/agents/frontend-dev/agent` | ✅ nuevo Sprint 3 |

Canónicos de Roy y mail-agent versionados en `The-Next-Security/tns-openclaw-agents` (repo privado, rama `dev`).
**Workers backend-dev y frontend-dev**: creados en VPS, pendiente push a repo de canónicos.

**Workers persistentes pendientes (Capa 2)**: `qa-analyst` — **NO creado todavía** (G-04).

---

## 4. Skills instaladas

`/root/.openclaw/skills/` — **17 skills**:

| Skill | Tipo |
|-------|------|
| `agent-audit-trail` | Governance |
| `backend-developer` | Rol Scrum |
| `coding-agent` | Tooling |
| `documentation-expert` | Rol Scrum |
| `frontend-developer` | Rol Scrum |
| `giraffe-guard` | Governance |
| `git-expert` | Rol Scrum |
| `github-manager` | Tooling |
| `governance-wrapper` | Governance |
| `product-owner` | Rol Scrum |
| `qa-analyst` | Rol Scrum |
| `scrum-master` | Rol Scrum |
| `skill-threat-scanner` | Governance |
| `tns-debugger-triage` | TNS custom |
| `tns-scrum-daily-standup` | TNS custom |
| `tns-track-deployer` | TNS custom |
| `ux-developer` | Rol Scrum |

---

## 5. Bugs conocidos y su estado

### Bug §13.2 — Subagent timeout → zombi → leak D-013

**Estado**: **mitigado** (exec allowlist Roy). Ticket upstream enviado: **openclaw/openclaw#76962**. Pendiente fix upstream.

### Bug G-24.d — Gateway envía mensajes de rate-limit propios a Telegram (NUEVO Sprint 3)

**Estado**: **nuevo — sin mitigación activa**.
**Síntoma**: cuando todos los modelos de la cadena fallan durante el procesamiento de un mensaje, el gateway envía su propio mensaje de sistema directo al canal Telegram (`"⚠️ Rate-limited — ready in ~30s. Please wait a moment."`), bypasseando la voz de Anibal. Viola D-013.
**Diferencia con §13.2**: no es un zombi; es el gateway mismo que habla. Vector distinto.
**Diagnóstico rápido**: si Felipe recibe mensajes con `⚠️` sin firma de Anibal, verificar cuotas de modelos.

---

## 6. Estado de cuotas (snapshot 2026-05-04 ~01:00 CEST)

> ⚠️ Verificar antes de hacer pruebas — los 3 modelos estaban limitados al cierre de sesión.

| Modelo | Estado | Reset estimado |
|--------|--------|----------------|
| `anthropic/claude-sonnet-4-6` | `disabled` (billing) en `auth-state.json` de Roy | **~05:46 CEST 2026-05-04** (5h desde fallo 00:46) |
| `openai-codex/gpt-5.4` | Rate limit ChatGPT Plus | **~31 hs desde ~00:40 CEST** |
| `openai-codex/gpt-5.3-codex` | Rate limit ChatGPT Plus | **~31 hs desde ~00:40 CEST** |

**Importante**: el pool CLI de Claude Pro (`claude -p`) es **separado** del pool web chat. El dashboard de claude.ai (Session/Weekly %) refleja el chat web, no el uso programático. Los sprint sessions intensivos del día agotaron el pool CLI. El web chat de Anibal sigue funcionando.

Para verificar estado actual del perfil Claude:
```bash
cat /root/.openclaw/agents/roy/agent/auth-state.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d,indent=2))"
```

---

## 7. Gaps — estado Sprint 3

### Cerrados en Sprint 3 (sesión 2026-05-04)

| Gap | Descripción | Estado |
|-----|-------------|--------|
| **G-02** | Worker `backend-dev` — canónicos + openclaw.json | ✅ Cerrado |
| **G-03** | Worker `frontend-dev` — canónicos + openclaw.json | ✅ Cerrado |

### G-13 — Validación e2e (PARCIALMENTE VALIDADO)

**Arquitectura validada**: la cadena Anibal → Roy → spawn subagente funcionó correctamente. Roy spawneó el subagente (`session:agent:roy:subagent:17124138`) en ambos intentos.

**Bloqueador**: cuotas agotadas en los 3 modelos (ver §6). El subagente no pudo ejecutar.

**Criterio pendiente de verificar** (cuando haya cuota):
```
[ ] backend-dev crea branch feature/test-hello-world en linux-push-to-talk
[ ] backend-dev hace commit de hello.py y abre PR a dev
[ ] anibalTNS aparece como autor del PR en GitHub
[ ] Roy reporta éxito a Anibal → Anibal informa a Felipe en Telegram
[ ] 0 mensajes crudos en Telegram (D-013 respetado)
```

**Tarea de prueba lista para reenviar cuando haya cuota**:
```
Roy, necesito que ejecutes una prueba de integración del sistema.
Delegale a backend-dev la siguiente tarea:

Repo: https://github.com/andresTNS/linux-push-to-talk
Branch base: dev
Branch nueva: feature/test-hello-world
Tarea: agregar un archivo hello.py en la raíz del repo con este contenido:
  print("Hello from TNS autonomous system")
Commit message: feat: add hello world test file
PR: abrir a dev con título "feat: hello world integration test" y descripción
que explique que es una prueba del sistema autónomo.
Reviewers: andresTNS

Criterio de éxito: PR abierto en GitHub por anibalTNS.
```

### Pendientes Sprint 3

| Gap | Descripción | Dependencias | Estimado |
|-----|-------------|-------------|----------|
| **G-13** | Validación e2e completa | Cuota modelos | Retomar ~05:46 CEST |
| **G-04** | Worker `qa-analyst` con canónicos | G-02, G-03 ✅ | ~20 min |
| **G-05** | Cron `daily-standup` (09:00 America/Santiago) | Roy ✅ | ~20 min |
| **G-06** | Cron `nightly-bugs-first` (03:00 America/Santiago) | G-02, G-03 ✅ | ~20 min |
| **G-07** | Cron `health-check-evening` (22:00 America/Santiago) | Roy ✅ | ~15 min |
| **G-10** | Backup automatizado diario | — | ~30 min |
| **G-11** | KPIs en markdown + alert Telegram si gateway cae | Roy ✅ | ~30 min |

### Deuda técnica (sin número de gap)

| Item | Descripción |
|------|-------------|
| G-24.b | `channels.telegram.botToken` aún en cleartext |
| G-24.c | `plugins.perplexity.apiKey` aún en cleartext |
| G-24.d | Gateway envía mensajes rate-limit propios a Telegram (violación D-013 menor) |
| G-08 | Skill `agent-dispatch` — evaluar si Roy la necesita |
| G-15 | Especialistas efímeros (debugger, node-specialist) validados |
| G-16 | Decisión: `sprint-manager.js` vs Roy autónomo |
| G-17 | Política de unblock + `start/completedAt` en backlog |
| Push canónicos | backend-dev y frontend-dev no están en `tns-openclaw-agents` repo todavía |

---

## 8. Reglas inviolables

1. **Regla #3 — 0 gasto por token**: solo OAuth. `usage.cost > 0` en `gpt-5.4` NO viola esta regla.
2. **Regla #5 — Branch protection by design**: ningún agente hace commit/push directo a `dev`/`main`/`master`. Protección vive en AGENTS.md/TOOLS.md. Citar siempre **"por diseño del agente"**.
3. **D-013 — Separación Anibal/Roy**: Anibal habla a Felipe en Telegram. Roy habla a Felipe solo vía Anibal (salvo 5 breakglass en HEARTBEAT.md de Roy).

---

## 9. Guardrails operativos

- **Diagnóstico read-only** (cat, jq, grep, ps, tail, ls): libre.
- **Cualquier acción de producción** (kill, systemctl restart, editar `openclaw.json`, git push): **requiere OK explícito de Felipe**.
- **Antes de editar `openclaw.json`**: backup `.bak.YYYYMMDD-HHMMSS.preX` → `jq empty` → esperar `lastKnownGood`.
- **CLI `openclaw`**: usar `/usr/bin/node /usr/lib/node_modules/openclaw/openclaw.mjs <subcommand>`
- **Proceso git**: feature branch desde `dev` → commits atómicos (1 archivo, push inmediato) → PR a `dev` → reviewers `andresTNS` (obligatorio) + uno de `felipecleverox`/`bufigol`/`TNSTRACK`. Nunca hacer merge.

---

## 10. Comandos útiles de referencia rápida

```bash
# Estado del gateway
systemctl status openclaw-gateway --no-pager

# Log en vivo
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# Verificar auth profiles (Regla #3)
jq '.auth.profiles | with_entries(.value |= {mode})' /root/.openclaw/openclaw.json

# Verificar agentes registrados
jq '.agents.list[] | {id, name}' /root/.openclaw/openclaw.json

# Verificar allowAgents de Roy
jq '.agents.list[] | select(.id=="roy") | .subagents' /root/.openclaw/openclaw.json

# Estado de cuotas / cooldown de modelos (Roy)
cat /root/.openclaw/agents/roy/agent/auth-state.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps(d,indent=2))"

# Verificar lastKnownGood del config
jq '.entries["/root/.openclaw/openclaw.json"].lastKnownGood | {hash, bytes, observedAt}' \
   /root/.openclaw/logs/config-health.json

# Backup openclaw.json
cp /root/.openclaw/openclaw.json \
   "/root/.openclaw/openclaw.json.bak.$(date +%Y%m%d-%H%M%S).pre-<DESCRIPCION>"
```

---

## 11. Backups en disco (historial)

| Archivo | Momento |
|---------|---------|
| `openclaw.json.bak.20260427-190608` | Pre-deploy original |
| `openclaw.json.bak.20260430-232522` | Pre-Sprint 0.5.ter |
| `openclaw.json.bak.20260501-170045.pre-0.5.quater` | Pre-Layer 1 |
| `openclaw.json.bak.20260501-175809-prelayer2config` | Pre-L2-config |
| `openclaw.json.bak.20260501-181433-pre-opcionA` | Pre-Opción A workspace |
| `openclaw.json.bak.20260501-182557-pre-G08-allowlist` | Pre-allowAgents |
| `openclaw.json.bak.20260502-024707.pre-G25` | Pre-bootstrapMaxChars |
| `openclaw.json.bak.20260502-232649.pre-F3` | Pre-thinking:none |
| `openclaw.json.bak.20260503-040627.pre-F4` | Pre-timeoutSeconds=300 |
| `openclaw.json.bak.20260503-042232.pre-G23` | Pre-fix workspace mail-agent |
| `openclaw.json.bak.20260503-235333.pre-G24` | Pre-gateway.auth.token → env |
| `openclaw.json.bak.20260504-XXXXXX.pre-G02-backend-dev` | Pre-workers Sprint 3 ← último |
| `exec-approvals.json.bak.20260502-021302.pre-M1` | Pre-exec policy Roy |

---

## 12. Prompt para nueva sesión

```
Continuación OpenClaw TNS — Sprint 3 (continuación).

Soy Felipe Vásquez (CEO TNS). Estás en el VPS Contabo `vmi3186391`
(207.180.249.180) vía Cursor Remote-SSH como root.
Workspace: openclaw-vps.code-workspace (3 folders: /root/.openclaw,
/opt/tns-workbench/autonomous-workbench, /opt/tns-workbench/tools).

DOCUMENTO PRINCIPAL (leer primero):
  @/root/.openclaw/handoff/SPRINT-3-HANDOFF.md

REGLAS INVIOLABLES (no negociables):
- Regla #3: solo OAuth, cero paid API token.
- Regla #5: nunca push/commit directo a dev/main/master. Citar "por diseño del agente".
- D-013: Roy responde a Anibal, NO directo a Felipe en Telegram.

ESTADO AL CIERRE SESIÓN 2026-05-04:
- G-02 CERRADO: backend-dev creado con 4 canónicos + registrado en openclaw.json.
- G-03 CERRADO: frontend-dev creado con 4 canónicos + registrado en openclaw.json.
- G-13 PARCIAL: arquitectura validada (spawn chain funciona). Bloqueado por cuotas.
  - claude-cli: disabled (billing) hasta ~05:46 CEST 2026-05-04
  - gpt-5.4 / gpt-5.3-codex: rate limit ChatGPT Plus ~31 hs desde ~00:40 CEST
- G-24.d NUEVO: gateway envía mensajes rate-limit propios a Telegram (D-013 menor).

OBJETIVO PRÓXIMA SESIÓN:
1. Verificar cuotas con auth-state.json de Roy.
2. Reenviar tarea de prueba a Anibal (texto en §7 de este handoff).
3. Completar G-13 (primera e2e real).
4. Seguir con G-04 (qa-analyst), G-05/G-07 (crons), G-10/G-11 (backup/KPIs).

GUARDRAILS:
- Read-only (cat, jq, grep, ps, tail, ls): libre.
- Producción (kill, restart, edit openclaw.json, git push):
  REQUIERE OK explícito de Felipe para cada acción concreta.
- Backup openclaw.json antes de editar.

CÓMO ARRANCAR:
1. Leé SPRINT-3-HANDOFF.md completo.
2. Verificá estado gateway: systemctl status openclaw-gateway --no-pager
3. Verificá cuotas: cat /root/.openclaw/agents/roy/agent/auth-state.json
4. Si claude-cli ya no está disabled → reenviar tarea de prueba G-13.
5. NO tocás producción hasta que yo apruebe la acción concreta.
```

---

> **Actualizado**: 2026-05-04 — sesión Sprint 3 parcial.
> **Historial**: `SPRINT-2.1-HANDOFF.md` → `SPRINT-2-HANDOFF.md` → `SPRINT-0-HANDOFF.md`.
