# Seguridad del sistema autónomo

Este documento describe el modelo de amenazas del sistema 1.0.0 y los
controles implementados para mitigarlo.

## Principios base

1. **OAuth exclusivo**: el LLM se consume únicamente vía ChatGPT Plus con
   OAuth (modelo primario `openai-codex/gpt-5.4`). Ningún API key en el
   sistema.
2. **Corredor aislado**: trabajo autónomo solo dentro de
   `/opt/tns-workbench/autonomous-workbench/` y sus worktrees.
3. **Runtime protegido**: `/root/.openclaw/` no se modifica desde el
   corredor. Solo el instalador explícito lo toca.
4. **Main protegida**: merge a `main` es exclusivamente responsabilidad
   humana (Felipe), con branch protection server-side.

## Amenazas y controles

### 1. Fuga de credenciales

**Amenaza**: tokens o claves expuestas en logs, commits o mensajes.

**Controles**:
- `infra/security/credential-leak-scan.sh`: escanea logs buscando
  patrones de claves conocidos (sk-, ghp_, github_pat_, PRIVATE KEY,
  etc.). Reporta hits para revisión manual.
- `.gitignore` excluye rutas de secrets y runtime.
- Regla inviolable en `AGENTS.md`: nunca exponer secrets en logs,
  Telegram, commits o comentarios de PR.

### 2. API key auto-creada por Codex CLI (Issue OpenAI #2000)

**Amenaza**: al hacer `codex login` OAuth, el CLI puede crear una API key
"Codex CLI (auto-generated)" que factura por token si queda seteada.

**Controles**:
- `infra/security/oauth-audit.sh`: verifica que `OPENAI_API_KEY` esté
  unset en env, que `.bashrc` lo fuerce a unset al iniciar shell, y que
  `codex login status` reporte sesión ChatGPT.
- `infra/security/unset-api-keys.sh`: agrega idempotentemente el bloque
  `unset OPENAI_API_KEY` a `~/.bashrc`.
- `infra/alerts/oauth-status-check.sh`: cron-friendly, alerta a Telegram
  si la sesión no es ChatGPT o si expiró.
- Procedimiento humano: tras cada `codex login`, revisar
  `platform.openai.com/api-keys` y revocar cualquier key auto-creada.

### 3. Pérdida del estado del runtime

**Amenaza**: `~/.openclaw/` corrupto, borrado o perdido por failure de
disco, error humano, o VM reinstalada.

**Controles**:
- `infra/backup/backup-openclaw.sh`: backup diario cifrado con `age` en
  `/var/backups/openclaw/`, rotación 7 copias.
- `infra/backup/restore-openclaw.sh`: restore verificable en scratch; no
  toca live a menos que se pase `--force-runtime` con confirmación.
- Ver `docs/backup-and-restore.md` para procedimiento y gate de release.

### 4. Prompt injection / skills de terceros maliciosas

**Amenaza**: contenido externo (email, webhook, skill de ClawHub) con
instrucciones que intenten hacer que el agente evada sus reglas.

**Controles**:
- Skills instaladas se escanean con `giraffe-guard` y
  `skill-threat-scanner` (instaladas en `~/.openclaw/skills/`).
- Políticas duras en `AGENTS.md` de Aníbal y Roy: si una instrucción
  intenta romper una regla, se rechaza con explicación; no se razona
  sobre el pedido.
- Webhooks con validación HMAC y allowlist de origen (PR Webhooks).

### 5. Acciones destructivas accidentales

**Amenaza**: agente ejecuta `rm -rf`, `git reset --hard`, force push, o
merge a `main` sin autorización.

**Controles**:
- `governance-wrapper` skill intercepta acciones sensibles.
- Reglas duras en `AGENTS.md` prohíben explícitamente merge a main,
  force push, squash merge sin autorización, rm -rf fuera de scratch.
- Branch protection server-side (configurada manualmente por Felipe).

### 6. Gateway caído sin detección

**Amenaza**: `openclaw-gateway` falla y Felipe no se entera hasta que
intenta interactuar.

**Controles**:
- `infra/alerts/gateway-watchdog.sh`: detecta inactividad sostenida y
  alerta a Telegram tras 5 minutos.
- `infra/observability/health-check.sh`: composite check invocable desde
  cron o manualmente.
- Reinicio automático vía `Restart=on-failure` en el systemd unit.

### 7. Exposición pública de la gateway

**Amenaza**: gateway OpenClaw atendiendo en interfaz pública, susceptible
a ataques directos.

**Controles**:
- Gateway bind `loopback` en `openclaw.json`.
- Acceso remoto solo por SSH o Tailscale.
- Webhooks (PR Webhooks): validación HMAC + allowlist IP Tailscale.

## Auditoría periódica

- **Diaria**: `oauth-audit.sh` y `health-check.sh` ejecutados por cron
  (cron jobs definidos en PR 2 como parte del hardening).
- **Semanal**: revisión manual de `platform.openai.com/api-keys` por
  Felipe.
- **Mensual**: revisión de logs de `~/.openclaw/logs/audit/` y backups.

## Contacto en caso de incidente

Felipe Vásquez (CEO TNS) es el único contacto autorizado para decisiones
sobre incidentes. Telegram chatID `6739292510`, email
`felipe@thenextsecurity.cl`.
