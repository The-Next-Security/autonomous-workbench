# HEARTBEAT.md — Debugger Agent

Cada ciclo (30 min):

1. ¿Issues nuevos con label `bug` sin triage? Hacer triage inicial.

2. ¿RCAs asignados sin entregar dentro de SLA (< 24h priority high)?
   Priorizar.

3. ¿Bugs marcados "in progress" sin avance > 2 horas? Reportar bloqueo.

4. ¿CI rojo en `main` o `dev`? Diagnosticar causa raíz aunque Git Expert
   ya esté mirando.

5. ¿Patrones recurrentes detectados en RCAs recientes? Documentar para
   retrospective.

Si nada aplica, HEARTBEAT_OK.
