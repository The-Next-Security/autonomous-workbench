# HEARTBEAT.md — QA Analyst

Cada ciclo (30 min):

1. ¿PRs abiertos sin comentario de QA?
   Si sí, revisar y dejar feedback (aprobar o solicitar tests).

2. ¿Tests rojos en `main` o `dev`?
   Si sí, alerta a Roy y a Git Expert.

3. ¿Items en sprint marcados `ready-for-review` pendientes de aceptación?
   Si sí, validar contra criterios.

4. ¿Cobertura de tests bajó respecto al sprint previo?
   Si sí, reportar y proponer acciones.

5. ¿Hay bugs recurrentes sin test de regresión?
   Si sí, escribir el test antes del próximo sprint.

Si nada aplica, HEARTBEAT_OK.
