# Autonomous Workbench
- Decisión: se crea worktree dedicada para aislar la validación e2e de Telegram.
- Decisión: el cambio será documental y no funcional para minimizar riesgo.

## OpenClaw Autonomous Rules

1. **Trazabilidad obligatoria**
   Toda acción autónoma que modifique estado en GitHub debe generar un comentario explicativo.

2. **Prohibición de acciones silenciosas**
   Una acción sin comentario se considera incompleta.

3. **Formato obligatorio de comentario**

   Usar siempre este formato:

   ```markdown
   ## Acción — OpenClaw

   ### Qué se hizo
   ...

   ### Por qué
   ...

   ### Regla aplicada
   ...
   ```

4. **Rama de integración**
   Todos los PR autónomos deben apuntar a `dev`. `main` no es una base válida.

