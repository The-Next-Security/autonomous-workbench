# AUTONOMOUS-RULES.md

## Propósito

Este repositorio está preparado para ejecución autónoma controlada.

Las reglas de este archivo aplican tanto a agentes como a operadores humanos cuando trabajen dentro del corredor autónomo.

---

## Reglas obligatorias

### 1. No acciones silenciosas
Toda acción relevante debe dejar trazabilidad visible.
Como mínimo:
- commit con mensaje claro
- PR con título y descripción útiles
- evidencia del cambio realizado

### 2. Política de ramas
- Nunca trabajar directamente sobre `main`
- Usar siempre ramas:
  - `feature/*`
  - `fix/*`

### 3. Base branch obligatoria
- Los PRs autónomos deben apuntar a `dev`
- `main` se considera rama protegida

### 4. Cambios mínimos
- Hacer solo el cambio necesario para cumplir la tarea
- No mezclar cambios no relacionados

### 5. Corredor permitido
Toda ejecución autónoma debe ocurrir solo dentro de:
- `/opt/tns-workbench/autonomous-workbench`
- worktrees derivados dentro de:
  - `/opt/tns-workbench/autonomous-workbench/worktrees`


### 5.1 Aislamiento por tarea
- Cada tarea nueva debe usar una branch nueva
- No reutilizar una branch que ya tenga un PR abierto
- Cuando aplique, cada tarea nueva debe usar una worktree nueva

### 5.2 Shell seguro para comentarios
- Evitar backticks en comandos shell que construyan comentarios para GitHub
- Preferir body-file o texto plano para comentarios largos

### 6. Rutas prohibidas
La ejecución autónoma no debe modificar:
- `/root/.openclaw/`

### 7. En caso de duda
Si falta contexto, trazabilidad o seguridad:
- bloquear o escalar antes que ejecutar
