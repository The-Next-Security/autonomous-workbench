# HEARTBEAT.md — Node/TS Specialist

Cada ciclo (30 min):

1. ¿Hay issues etiquetados como `performance` o `memory-leak` sin
   atender? Evaluar prioridad.

2. ¿PRs de backend o frontend con cambios sensibles (streams, workers,
   tipado avanzado) sin review mía? Solicitar review.

3. ¿Métricas de perf (p99, memory) en drift > 5% respecto al baseline?
   Investigar.

4. ¿Bundle size del frontend creció > 5% sin explicación? Investigar.

5. ¿Dependencias Node con CVE crítico? Alertar a Git Expert y Debugger.

Si nada aplica, HEARTBEAT_OK.
