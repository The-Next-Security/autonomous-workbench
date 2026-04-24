# Políticas duras del sistema

Este documento describe las tres políticas operativas que rigen la
autonomía del equipo. Están referenciadas desde `AGENTS.md` de Roy y
heredadas por todos los especialistas.

## Bugs First

Antes de trabajar en features nuevas, el sistema revisa issues con label
`bug` en los repos prioritarios. Si hay al menos un bug abierto, el flujo
es:

1. Spawnear al Debugger Agent para hacer RCA (root cause analysis) del
   bug.
2. Debugger produce un documento RCA en `~/tns-debug/rca-<issue-id>.md`.
3. Con el RCA en mano, Roy spawnea al Dev correspondiente para aplicar
   el fix.
4. Una vez mergeado el fix, el flujo de features continúa.

**Por qué:** evita acumulación de deuda técnica operativa y garantiza
que el software que el sistema despliega no regrese en funcionalidad.

**Excepciones:**
- Bugs marcados `wontfix` no bloquean features.
- Si Felipe marca explícitamente que una feature es prioridad máxima,
  Roy puede invertir el orden con autorización escrita.

## One Worktree One Agent

Nunca dos coding agents ejecutan trabajo simultáneo sobre la misma
worktree.

**Regla operativa:**
- Para ejecutar una tarea de código: worktree dedicada en
  `/opt/tns-workbench/autonomous-workbench/worktrees/<slug>/`.
- Para paralelizar dos tareas: dos worktrees distintas.
- Al terminar, la worktree se deja hasta que el PR derivado se cierre
  (merge o close). Luego se limpia con `git worktree remove`.

**Por qué:** evita conflictos de estado, archivos parcialmente escritos,
y condiciones de carrera. También simplifica el rollback: si una
worktree queda corrupta, se descarta sin afectar las demás.

**Aplicación:**
- Roy verifica antes de spawnear: si la worktree objetivo ya tiene
  trabajo, rechaza con explicación.
- Los especialistas leen su `AGENTS.md` y saben que solo pueden operar
  en la worktree que Roy les asignó.

## Ralph Wiggum (reinicio fuerte de contexto)

Esta política aplica a loops de revisión iterativa de un mismo PR.

**Regla:**
- Máximo 3 iteraciones de revisión por PR.
- Entre iteraciones, se aplica un hard context reset al sub-agente
  encargado de aplicar cambios: se descarta su historial conversacional
  y arranca limpio leyendo solo los artefactos del PR (diff, comentarios
  del reviewer, tests que fallan).

**Por qué:** un agente que iteró varias veces sobre un mismo código
tiende a defender sus decisiones anteriores, acumula contexto irrelevante,
y pierde capacidad de ver el problema con ojos frescos. El hard reset
elimina ese sesgo. El nombre viene del personaje Ralph Wiggum de Los
Simpson, que ilustra con humor la idea de volver a empezar desde cero
sin memoria del intento anterior.

**Implementación técnica:**
- Tras iteración 1: revisor comenta en el PR.
- Iteración 2: nuevo proceso del agente, sin contexto previo, lee solo
  el PR y los comentarios.
- Si tras iteración 3 el PR sigue sin pasar, Roy escala a Felipe.

**Aplicación en 1.0.0:**
- Mientras no haya webhooks ni auto-review automáticos, la política se
  aplica manualmente por Roy cuando coordina iteraciones con los devs.
- A partir de iteraciones futuras (fuera de 1.0.0), el reset se
  automatiza en hooks del flujo de review.

## Relación con la política OAuth

Todas las políticas anteriores son complementarias a la política OAuth
exclusiva del sistema (ver `AGENTS.md` sección 2.11). Ninguna política
operativa puede pedir o justificar el uso de `OPENAI_API_KEY` u otras
claves. Si una iteración falla por cuota agotada de ChatGPT Plus, se
escala a Felipe y se espera, no se cambia de proveedor.
