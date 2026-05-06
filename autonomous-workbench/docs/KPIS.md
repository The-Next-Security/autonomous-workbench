# KPIS — Snapshot del sistema autónomo

Generado automáticamente por `infra/observability/compute-kpis.sh`.

- Fecha del snapshot: 2026-05-06T18:35:32Z
- Versión objetivo: 1.0.0

## Pull Requests por repositorio (últimos 30 días)

| Repo | Abiertos | Mergeados (30d) | Cerrados sin merge (30d) |
|------|----------|-----------------|--------------------------|
| The-Next-Security/autonomous-workbench | 0 | 16 | 10 |
| The-Next-Security/scrum-files | 0 | 1 | 0 |
| The-Next-Security/agents-files | 0 | 3 | 0 |

## Gateway health

- systemd user service `openclaw-gateway`: **inactive
unknown**

## OAuth status

- codex login status: Logged in using ChatGPT

## Cron jobs configurados

- Total: 7
- Activos: 4

| Nombre | Activo | Schedule |
|--------|--------|----------|
| lobster-day3-visit | false | 2026-04-24T04:00:00.000Z |
| lobster-day3-report | false | 2026-04-24T05:45:00.000Z |
| ai-rigorous-daily-digest | false | 0 5 * * * |
| daily-standup | true | 0 9 * * 1-5 |
| nightly-bugs-first | true | 0 3 * * * |
| health-check-evening | true | 0 22 * * * |
| sprint-pickup | true | 0 8 * * 1 |

## Disk usage (raíz)

| Filesystem | Size | Used | Avail | Use% | Mounted |
|---|---|---|---|---|---|
| /dev/sda1 | 193G | 36G | 158G | 19% | / |

## Notas

- KPIs de velocity de sprint se calculan desde `~/.openclaw/scrum/sprint-state.json` en iteraciones posteriores.
- Métricas de defect-escape rate y time-to-PR requieren la tabla de release de la 1.0.0 ya estabilizada.
- Este documento se regenera en cada ejecución del script.
