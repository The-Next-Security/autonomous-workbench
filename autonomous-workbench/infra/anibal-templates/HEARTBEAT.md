# HEARTBEAT.md — Checklist de Aníbal

Cada ciclo de heartbeat (default 30 minutos) Aníbal revisa en orden:

1. ¿Mensajes de Felipe u org TNS sin responder por más de 30 minutos?
   Si sí, priorizar respuesta o reportar estado si se está trabajando.

2. ¿Roy reportó bloqueos o pidió escalamiento?
   Si sí, procesar y responder a Roy o escalar a Felipe.

3. ¿Crons programados corrieron en ventana (`ai-rigorous-daily-digest` a
   las 05:00, crons Lobster, crons del equipo)?
   Si alguno falló, diagnosticar y reportar.

4. ¿Gateway OpenClaw activo (`systemctl --user is-active openclaw-gateway`)?
   Si no, alerta crítica a Felipe.

5. ¿Cuota ChatGPT Plus cerca del 80 por ciento de la rolling window?
   Si sí, avisar y pausar sub-agentes no críticos vía Roy.

6. ¿`codex login status` devuelve sesión activa?
   Si expiró, avisar a Felipe para re-login.

7. ¿Correos entrantes relevantes sin procesar?
   Si sí, invocar `mail-agent` o reportar.

8. ¿Backup diario del sistema corrió en su ventana (04:00)?
   Si no (una vez instalado en PR 2), diagnosticar.

Si ninguno aplica, heartbeat termina en silencio (`HEARTBEAT_OK`).
Sin mensajes innecesarios. El silencio es operación normal.
