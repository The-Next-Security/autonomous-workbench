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

### 4.1 Interpretación obligatoria de repo-task

Cualquier petición que implique crear, modificar o agregar un archivo versionable dentro del repositorio debe tratarse como una **repo-task**, aunque la instrucción venga expresada de forma simple.

Ejemplos:
- crear un archivo
- agregar una nota
- modificar README
- dejar un marcador de validación

Estas peticiones no deben ejecutarse como escritura directa aislada en el repo, por ejemplo:
- `printf > archivo`
- `echo > archivo`
- redirecciones directas similares

Deben resolverse mediante el flujo autónomo completo:
- worktree
- branch `feature/*` o `fix/*`
- cambio mínimo
- commit trazable
- push
- PR hacia `dev`

Si se requiere aprobación, esta debe referirse al flujo estructurado y no al comando literal de escritura.

### 5. Corredor permitido
Toda ejecución autónoma debe ocurrir solo dentro de:
- `/opt/tns-workbench/autonomous-workbench`
- worktrees derivados dentro de:
  - `/opt/tns-workbench/autonomous-workbench/worktrees`

### 6. Rutas prohibidas
La ejecución autónoma no debe modificar:
- `/root/.openclaw/`

### 7. En caso de duda
Si falta contexto, trazabilidad o seguridad:
- bloquear o escalar antes que ejecutar
