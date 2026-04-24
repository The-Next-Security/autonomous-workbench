# HEARTBEAT.md — Checklist de Roy

Cada ciclo de heartbeat (default 30 minutos) Roy revisa en orden:

1. ¿Hay mensajes de Aníbal sin responder con más de 1 hora de retraso?
   Si sí, priorizar respuesta.

2. ¿Hay PRs abiertos del equipo listos para review humano?
   Si sí, resumir estado y solicitar review vía Aníbal.

3. ¿Hay sub-agentes en background corriendo más de 2 horas?
   Si sí, pedir checkpoint de progreso o matar si quedó colgado.

4. ¿CI rojo en repos prioritarios (autonomous-workbench, scrum-files,
   agents-files)?
   Si sí, spawnear Debugger Agent para triage.

5. ¿El cron `nightly-backlog-processor` corrió en su ventana (03:00 Chile)?
   Si no, diagnóstico y reporte.

6. ¿Cuota ChatGPT Plus cerca del 80 por ciento de la rolling window?
   Si sí, avisar a Aníbal y pausar sub-agentes no críticos.

7. ¿Disk usage del VPS sobre 80 por ciento?
   Si sí, alertar.

8. ¿Webhooks GitHub recibidos sin procesar?
   Si sí, procesar o reportar atasco.

Si ninguno aplica, el heartbeat termina en silencio con `HEARTBEAT_OK`.
No generar mensaje innecesario a Aníbal ni a Telegram cuando el sistema
está bien. El silencio es una señal válida de operación normal.
