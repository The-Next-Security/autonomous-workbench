# HEARTBEAT.md — Checklist de Roy

Cada ciclo de heartbeat (default 30 minutos) Roy revisa en orden los
ítems siguientes. La regla es: **silencio por defecto**. Solo genera
mensaje a Aníbal (y de allí a Telegram) cuando algún punto requiere
atención humana o acción no trivial.

## Revisión de mensajes humanos pendientes

1. ¿Mensajes de Aníbal para Roy sin respuesta con más de 1 hora de
   retraso? Si sí, priorizar respuesta o reportar estado si el
   trabajo está en curso.

2. ¿Comentarios nuevos en PRs abiertos del sistema por parte de
   `felipecleverox`, `Bufigol`, `TNSTRACK`, `andresTNS`? Si sí, leer,
   evaluar, y responder o actuar según corresponda. Los comentarios
   de reviewers son instrucciones con prioridad alta.

3. ¿Comentarios nuevos en issues abiertos por alguno de los humanos
   autorizados? Si sí, leer y actuar si hay pedido concreto.

## Revisión del trabajo del equipo

4. ¿PRs abiertos del equipo listos para review humano (CI verde,
   comentarios de QA resueltos)? Si sí, resumir estado y solicitar
   review vía Aníbal.

5. ¿PRs abiertos con cambios solicitados por reviewers que lleven
   más de 24 horas sin atender? Si sí, spawnear al especialista
   correspondiente para aplicar los cambios.

6. ¿Sub-agentes spawneados en background corriendo más de 2 horas
   sin reportar? Si sí, pedir checkpoint o matar si quedó colgado;
   reportar.

7. ¿Hay bloqueos abiertos reportados por algún especialista en su
   heartbeat? Si sí, coordinar resolución o escalar.

## Revisión por repositorio

Para cada repositorio activo en el sprint actual (incluyendo los 3
repos base del sistema y cualquier repo adicional que el sistema esté
trabajando por instrucción humana):

8. ¿CI en rojo en `main` o `dev`? Si sí, spawn Debugger para triage;
   Git Expert revisa workflow.

9. ¿Pull desde origin antes de tocar tracked files? Verificar que la
   branch local está actualizada.

10. ¿Issues nuevos con label `bug` o con mención a `@anibalTNS`? Si
    sí, aplicar política de excepción (ver `docs/policies.md` y
    `AGENTS.md` de Aníbal).

11. ¿PRs mergeados sin update del `CHANGELOG.md` del repo? Si sí,
    spawnear Docs Expert para actualizar antes del próximo release.

## Revisión del runtime y la infraestructura

12. ¿Gateway OpenClaw activo?
    (`systemctl --user is-active openclaw-gateway`). Si no, alerta
    crítica a Aníbal.

13. ¿Cron del equipo ejecutado en su ventana
    (`daily-standup 09:00`, `nightly-backlog-processor 03:00`,
    `health-check-evening 22:00`, `weekly-report lunes 09:00`)?
    Si alguno falló, diagnosticar y reportar.

14. ¿Cuota ChatGPT Plus cerca del 80% de la rolling window?
    Si sí, avisar a Aníbal y pausar sub-agentes no críticos.

15. ¿`codex login status` devuelve sesión activa? Si expiró, avisar
    para re-login manual; recordar revisar
    `platform.openai.com/api-keys` para revocar keys auto-creadas.

16. ¿Disk usage VPS sobre 80%? Si sí, alertar.

17. ¿Backup del runtime ejecutado en su ventana (04:00)? Si no (tras
    instalar PR 2 de 1.0.0), diagnosticar.

## Revisión de necesidades humanas pendientes

18. ¿Se detectó alguna necesidad que requiere intervención humana y
    aún no se reportó? Si sí, redactar aviso según formato de
    `TOOLS.md` ("Necesidad detectada / Por qué / Cómo se resuelve /
    Bloqueo") y enviar a Aníbal.

19. ¿Hay dependencias, APIs, recursos o permisos pendientes de
    confirmación humana que estén bloqueando trabajo del equipo? Si
    sí, recordar con un mensaje compacto.

## Salida del heartbeat

Si ninguno de los puntos anteriores requiere acción: **silencio
total**. Cerrar con `HEARTBEAT_OK` sin enviar mensaje a Telegram. El
silencio es señal válida de operación normal y evita ruido para el
humano.

Si hay acciones tomadas o alertas emitidas: consolidar en un solo
mensaje a Aníbal al final del ciclo; nunca múltiples mensajes por
heartbeat.
