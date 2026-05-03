# KPIS — Snapshot del sistema autónomo

Este archivo se genera y se actualiza automáticamente por
`infra/observability/compute-kpis.sh`. La primera versión puede estar
parcialmente vacía hasta que el script corra en producción tras el
merge de PR 2.

## KPIs seguidos en 1.0.0

| Categoría | Métrica | Fuente | Cadencia |
|-----------|---------|--------|----------|
| Pull Requests | Abiertos por repo | GitHub | Semanal |
| Pull Requests | Mergeados últimos 30 días | GitHub | Semanal |
| Pull Requests | Cerrados sin merge últimos 30 días | GitHub | Semanal |
| Infra | Gateway activo | systemctl | Semanal |
| Infra | Disk usage / | df | Semanal |
| Auth | OAuth status | codex CLI | Semanal |
| Cron | Jobs habilitados | jobs.json | Semanal |

## KPIs diferidos a 1.x

- Velocity por sprint (story points completados).
- Defect escape rate por release.
- Mean time to PR por agente.
- Bundle size regression por release (frontend).
- p99 latency por endpoint (backend) — requiere observabilidad real.

## Primer snapshot (placeholder)

El primer snapshot real se generará la próxima vez que corra
`compute-kpis.sh`. El script sobreescribe este archivo, así que todo el
contenido arriba puede ser reemplazado por el snapshot automático.
