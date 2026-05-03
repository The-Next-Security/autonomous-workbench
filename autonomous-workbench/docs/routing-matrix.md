# Matriz de ruteo de Roy

Roy usa esta matriz para decidir qué especialista spawnear según el
trigger de la tarea. Los triggers son palabras o intenciones que
aparecen en la instrucción recibida (sea vía Aníbal, comentario de PR,
o issue).

## Matriz principal

| Trigger / intención | Especialista primario | Especialistas secundarios |
|---------------------|-----------------------|---------------------------|
| "backlog", "prioriza", "user story", "historia", "refinamiento" | product-owner | docs-expert (si hay que documentar) |
| "tests", "acceptance", "regresión", "cobertura" | qa-analyst | backend-dev o frontend-dev (para arreglar lo que falla) |
| "UI", "pantalla", "componente", "responsive", "CSS" | frontend-dev | ux-dev (si hay diseño faltante) |
| "endpoint", "API", "BD", "DB", "servicio", "integración" | backend-dev | node-specialist (si hay perf crítica) |
| "flow", "wireframe", "diseño", "journey" | ux-dev | frontend-dev (cuando se implementa) |
| "rebase", "merge conflict", "CI falla", "hook de git" | git-expert | - |
| "README", "CHANGELOG", "spec", "documenta", "wiki" | docs-expert | product-owner (si es historia de producto) |
| "memory leak", "performance", "event loop", "tipos TS avanzados" | node-specialist | backend-dev o frontend-dev |
| "bug", "error", "stack trace", "reproduce", "diagnostica" | debugger | dev correspondiente al fix (tras RCA) |

## Reglas de decisión cuando hay ambigüedad

### Feature multi-capa (frontend + backend)
Roy spawnea secuencialmente:
1. product-owner refina historia y acceptance criteria.
2. ux-dev produce wireframes si faltan.
3. backend-dev y frontend-dev trabajan en paralelo (worktrees distintas).
4. qa-analyst valida integración.
5. docs-expert actualiza README o spec.
6. git-expert abre PR a `dev`.

### Bug con impacto cruzado
Si un bug afecta frontend y backend:
1. debugger hace RCA completo primero.
2. RCA identifica la capa raíz.
3. Roy spawnea al dev de esa capa.
4. Si el fix requiere cambio en la otra capa, se coordina en el mismo PR
   con commits separados.

### Tarea que parece no coincidir con ningún especialista
Si la instrucción no encaja claramente en la matriz:
1. Roy consulta con Aníbal.
2. Si Aníbal no puede clarificar, escalar a Felipe con pregunta acotada.
3. No improvisar asignando al "más cercano".

## Tarea que Roy maneja directo (sin spawnear)

Roy no delega cuando:
- Es coordinación pura (responder estado, reportar progreso, mover
  items entre columnas del backlog).
- Es ceremonia Scrum (abrir sprint, cerrar sprint, standup).
- Es decisión de ruteo (la tarea no tiene implementación todavía).
- Es rechazo por violación de políticas.

## Ceremonias Scrum (Roy facilita)

| Ceremonia | Frecuencia | Trigger |
|-----------|------------|---------|
| Sprint Planning | Inicio de sprint (1 o 2 semanas) | manual por Aníbal o Felipe |
| Daily Standup | Diario 09:00 Chile | cron `daily-standup` (instalado en PR 1.1) |
| Sprint Review | Fin de sprint | manual + cron weekly-report |
| Sprint Retrospective | Fin de sprint | manual |
| Backlog Refinement | Cada 3 días aproximadamente | heartbeat |

## Matriz de autoridad (decisiones escalables)

| Decisión | Quién decide autónomo | Escala a |
|----------|------------------------|----------|
| Orden de items en sprint activo | product-owner | Aníbal -> Felipe |
| Acceptance criteria | product-owner + qa-analyst | Aníbal si hay ambigüedad de negocio |
| Diseño UI/UX específico | ux-dev | Felipe si cambia branding |
| Arquitectura técnica nueva | Roy + node-specialist | Felipe si cambia stack |
| Implementación detallada | Dev correspondiente | Roy si hay trade-off significativo |
| Estrategia de branches y merges | git-expert | Nunca (puramente técnica) |
| Merge a `main` | Nadie autónomo | Siempre Felipe |
| Gasto en cuenta externa | Nadie autónomo | Siempre Felipe |
| Publicación externa (LinkedIn, web) | docs-expert para contenido interno | Siempre Felipe para externo |
