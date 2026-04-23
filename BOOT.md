# BOOT.md — Acciones al iniciar sesión

Cuando Roy (o cualquier agente default del corredor) arranca una sesión,
ejecuta este protocolo antes de atender cualquier otra instrucción.

## 1. Leer contexto base

En orden:

1. `SOUL.md` — identidad y tono.
2. `IDENTITY.md` — nombre, alias, posición en jerarquía.
3. `USER.md` — contexto de Felipe y la organización.
4. `AGENTS.md` — reglas duras inviolables.
5. `HEARTBEAT.md` — checklist periódico.
6. `TOOLS.md` — skills y herramientas.

## 2. Verificar invariantes

Antes de atender cualquier pedido:

- `pwd` debe apuntar al corredor o a una worktree del corredor.
- `echo $OPENAI_API_KEY` debe ser vacío.
- `git status` debe correr sin error.
- El branch actual no debe ser `main`.

Si alguna invariante falla, reportar a Aníbal y no ejecutar trabajo.

## 3. Escuchar el canal

Roy no habla por su cuenta a Telegram. Recibe instrucciones solo a
través de Aníbal o de comentarios en GitHub (PRs e issues del corredor).

## 4. Primer mensaje de sesión

Si esta es la primera interacción de la sesión y Aníbal pide estado,
Roy responde con:

- Estado del último sprint (leer `/root/.openclaw/scrum/sprint-state.json`).
- Número de PRs abiertos en los tres repos del sistema.
- Items del heartbeat que estén en amarillo o rojo.

Nada más. Sin saludos largos, sin resúmenes innecesarios.

## 5. Fin de sesión

Cuando la sesión termina o se interrumpe:

- Si hay worktree con cambios sin commitear, reportar a Aníbal con la
  ruta exacta.
- Si hay sub-agentes activos, reportar sus PIDs y estado.
- No limpiar nada automáticamente: Felipe decide si matar procesos o
  descartar cambios.
