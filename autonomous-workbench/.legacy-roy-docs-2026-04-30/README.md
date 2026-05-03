# Legacy Roy canonicals — archived 2026-04-30

## Qué hay acá

Cinco archivos canónicos que vivían en `/opt/tns-workbench/autonomous-workbench/`
(workspace de código de Anibal) y que se referían a **Roy** en su contenido:

- `SOUL.md` (1937 B, "# SOUL.md — Roy")
- `AGENTS.md` (5922 B, "# AGENTS.md — Reglas operativas de Roy (Scrum Master)")
- `BOOT.md` (5257 B, "# BOOT.md — Protocolo de arranque de sesión de Roy")
- `HEARTBEAT.md` (3970 B, "# HEARTBEAT.md — Checklist de Roy")
- `TOOLS.md` (7944 B, "# TOOLS.md — Herramientas de Roy (Scrum Master)")

## Por qué se archivaron

Antes de la **D-013 (2026-04-27, master guide v3.0.1)**, el sistema operaba bajo una
doctrina de **agente unificado**: un único agente que tenía SOUL "Roy" y vivía en el
corredor `/opt/tns-workbench/autonomous-workbench/`.

D-013 introdujo la separación clara **Anibal (Capa 0) ↔ Roy (Capa 1)**:

- Anibal = `agents.list[main]`, recibe Telegram, persona pública.
- Roy = `agents.list[roy]`, Scrum Master, único con heartbeat.

Los agentDirs y workspaces canónicos nuevos se crearon para cada uno
(`/root/.openclaw/agents/{main,roy}/`, y luego en Sprint 0.5.ter se agregó
`/root/.openclaw/workspaces/roy/`), **pero los .md viejos quedaron en el corredor**.

Resultado observado en G-12 retest (2026-04-30 22:20-22:25 UTC):

- Felipe pidió "delegale a Roy una health-check con cita textual de SOUL.md".
- Anibal **no invocó a Roy** (sin tool calls a sessions_spawn / Task).
- En cambio, gpt-5.4 (vía model fallback tras timeout de claude-cli) generó la
  respuesta **citando este SOUL.md viejo** que estaba en el cwd de Anibal.
- Felipe recibió un reporte que contenía:
  - Path "workspace": `/opt/tns-workbench/autonomous-workbench` (línea 38 de
    este SOUL.md: `Nunca trabajo fuera del corredor /opt/tns-workbench/...`).
  - "Cita textual": `"Soy Roy. Soy el Scrum Master del corredor autónomo de TNS. "Roy" y"`
    (líneas 3-4 de este SOUL.md, cortado al carácter "y").
  - Sección "2.3" y "2.12" del AGENTS.md (esa numeración no existía en el
    workspace nuevo de Roy — sí en este AGENTS.md viejo).

## Acción

Sprint 0.5.quater Layer 1: estos 5 archivos se movieron del cwd de Anibal a
este archive, fuera del bootstrap path que Anibal lee como reference. El move
se hizo sin commit ni push, dejándolos como `D` (deleted) en `git status` de
`dev`. Reversible con `git restore SOUL.md AGENTS.md BOOT.md HEARTBEAT.md TOOLS.md`
(restaura desde el último commit).

## Próximos pasos

- Sprint 0.5.quater Layer 2: redactar canónicos correctos para Anibal v3.0.1
  en `/root/.openclaw/workspaces/main/` (paralelo al de Roy).
- Decisión pendiente con Felipe: ¿commitear+pushear este archive a una
  feature branch del repo, o mantenerlo solo local?

## Integridad

md5 de los archivos preservada en backup pre-archive:
`/root/.openclaw/handoff/cwd-anibal-snapshot-pre-0.5.quater-20260501-170045.txt`

Backup paralelo de `openclaw.json`:
`/root/.openclaw/openclaw.json.bak.20260501-170045.pre-0.5.quater`
