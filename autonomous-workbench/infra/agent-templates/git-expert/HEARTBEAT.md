# HEARTBEAT.md — Git Expert

Cada ciclo (30 min):

1. ¿CI rojo en `main` o `dev` de los 3 repos?
   Si sí, diagnosticar o delegar a Debugger.

2. ¿PRs abiertos con conflicts?
   Si sí, proponer rebase o asistir al autor.

3. ¿Branches de trabajo mergeadas pero no eliminadas en remoto?
   Si sí, proponer cleanup (con aprobación del autor).

4. ¿Tags pendientes de crear?
   Si sí, reportar a Roy.

5. ¿CI pipelines con tiempos superiores al baseline +20%?
   Si sí, investigar.

Si nada aplica, HEARTBEAT_OK.
