# Observabilidad mínima

El nivel de observabilidad apuntado para 1.0.0 es deliberadamente
básico: health checks, logs, KPIs en markdown. Dashboards avanzados
(Grafana/Loki, agent-dashboard) quedan como trabajo posterior.

## Componentes

### Health check

`infra/observability/health-check.sh` verifica en una sola ejecución:

- Estado del gateway (`systemctl --user is-active`).
- Disk usage.
- OAuth status (`codex login status` reporta ChatGPT).
- Presencia y conteo de cron jobs habilitados.
- API keys en env (deben estar unset).

Comportamiento silencioso por defecto: si todo está bien, no hace ruido.
Si hay problemas, envía un solo mensaje Telegram con el listado.

### KPIs markdown

`infra/observability/compute-kpis.sh` regenera `docs/KPIS.md` con un
snapshot del sistema: PRs por repo, health del gateway, OAuth status,
cron jobs configurados, disk usage.

Pensado para ejecutarse como parte del cron `weekly-report` o bajo
demanda desde Telegram.

### Logs

Ubicación primaria: `~/.openclaw/logs/`. Las sub-rutas actuales:

- `~/.openclaw/logs/` — logs generales del gateway.
- `~/.openclaw/logs/audit/` — audit trail hash-chained (skill
  `agent-audit-trail`, activada como parte de PR 2 si se configura).
- `~/.openclaw/logs/gateway-watchdog.state` — estado del watchdog.

No se exponen logs por HTTP. Acceso vía SSH o Tailscale.

### Telegram alerts

Scripts que pueden alertar a Felipe:

- `gateway-watchdog.sh` — gateway inactivo > 5 min.
- `oauth-status-check.sh` — sesión OAuth caída o no-ChatGPT.
- `quota-watcher.sh` — cuota ChatGPT Plus > 80% (mejor esfuerzo).
- `health-check.sh` — agregado de los anteriores.

Todos usan el helper `infra/lib/telegram-notify.sh` que lee el token
del `openclaw.json` y envía al chatID `6739292510`. No interceptan ni
reemplazan mensajes entrantes del bot de Aníbal.

## Cadencia recomendada

| Script | Frecuencia | Modo |
|---|---|---|
| `gateway-watchdog.sh` | Cada 2 min (systemd timer o cron) | Silent unless fail |
| `oauth-status-check.sh` | Cada 6 horas | Silent unless fail |
| `health-check.sh` | Cada hora | Silent unless fail |
| `compute-kpis.sh` | Semanal (Lunes 09:00) | Escribe docs/KPIS.md |
| `credential-leak-scan.sh` | Semanal | Silent unless hits |

La instalación de estos schedules queda como trabajo post-merge por
responsable humano; no se inyectan automáticamente al mergear el PR.

## Qué NO está en 1.0.0

- Dashboards interactivos (Grafana, Loki).
- Métricas de agente individuales en tiempo real.
- Trazas distribuidas.
- SIEM.
- Alertas cruzadas con servicios externos.

Están documentadas en el backlog 1.x para iteraciones futuras.
