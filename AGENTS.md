# AGENTS.md — Autonomous Behavior Rules

## 1. Principio general

El sistema debe comportarse de forma autónoma, trazable y segura, sin depender de prompts largos.

---

## 2. Reglas obligatorias de ejecución

### 2.1 No acciones silenciosas
- Toda acción relevante debe dejar evidencia
- Especialmente en GitHub (PR o issue)

### 2.2 Trazabilidad obligatoria
- Cada commit debe tener mensaje claro
- Cada PR debe incluir descripción del cambio

### 2.3 Política de ramas
- Nunca trabajar directamente sobre main
- Usar siempre:
  - feature/*
  - fix/*
- Los PRs deben apuntar a: dev

### 2.4 Cambios mínimos
- Realizar solo lo necesario para cumplir la tarea
- Evitar cambios masivos o no relacionados

### 2.5 Un commit por cambio lógico
- No mezclar múltiples cambios en un mismo commit

---

## 3. Flujo operativo esperado

Para cualquier tarea:

1. Crear worktree
2. Crear branch
3. Realizar cambio mínimo
4. Commit
5. Push
6. Crear PR

---

## 3.1 Regla de interpretación de repo-task

Se debe tratar como **repo-task** cualquier petición que implique crear, modificar o agregar un archivo versionable dentro del repositorio, aunque la instrucción del usuario sea simple.

Ejemplos:
- "crea un archivo ..."
- "agrega una nota ..."
- "modifica README ..."
- "deja un marcador de validación ..."

Estas peticiones no deben traducirse a comandos literales aislados como:
- `printf > archivo`
- `echo > archivo`
- redirecciones directas sobre archivos del repo

En su lugar, deben reinterpretarse como una unidad completa de trabajo autónomo.

### Flujo obligatorio para una repo-task

1. crear worktree aislada si corresponde
2. crear branch nueva `feature/*` o `fix/*`
3. realizar el cambio mínimo
4. validar estado del repo
5. generar commit trazable
6. hacer push
7. abrir PR hacia `dev`

### Regla de aprobación

Si se requiere aprobación, la aprobación debe pedirse sobre el **flujo estructurado de repo-task** y no sobre el comando shell literal que escribe el archivo.

### Prohibición explícita

No proponer ni ejecutar escritura directa aislada en el repo raíz cuando el cambio corresponda a una tarea nueva.

## 4. Reglas de seguridad

- No operar fuera de:
  /opt/tns-workbench/autonomous-workbench

- No modificar:
  /root/.openclaw/

---

## 5. Reglas de fallback

Si hay ambigüedad:
- detener ejecución
- pedir contexto

Si hay riesgo:
- escalar o bloquear

---

## 6. Objetivo del sistema

El sistema debe:
- ejecutar tareas completas
- dejar trazabilidad
- operar sin prompts largos


## Repo Task Operational Contract

Cuando una instrucción del usuario implique crear, modificar o agregar archivos versionables dentro de este repositorio, el agente debe tratarla como una tarea completa de repositorio y no como escritura directa aislada.

### Mandatory flow

1. crear una worktree nueva por tarea
2. crear una branch nueva `feature/*` o `fix/*`
3. aplicar el cambio mínimo necesario
4. hacer commit trazable
5. hacer push
6. abrir PR hacia `dev`, nunca hacia `main`

### No redundant conversational reconfirmation

Si la instrucción del usuario ya es suficientemente clara, el corredor ya está definido y no hay bloqueo real, el agente no debe responder con frases como:

- “si quieres, ejecuto ese flujo”
- “necesito confirmar antes de continuar”
- “puedo hacerlo si me lo indicas”

Debe continuar directamente con la ejecución autorizada.

Solo debe detenerse si existe:

- error real
- bloqueo real
- ambigüedad material
- falta de información indispensable

### One task, one worktree, one branch

Cada tarea nueva debe usar su propia worktree y su propia branch.

No reutilizar una branch con PR abierto para una tarea nueva.

### GitHub traceability is mandatory

Toda acción autónoma relevante en GitHub debe dejar comentario obligatorio.

Formato obligatorio:

## Acción — OpenClaw

### Qué se hizo
...

### Por qué
...

### Regla aplicada
...

Una acción sin comentario se considera incompleta.

### Safe comment publishing rule

Para publicar comentarios largos en PRs o issues:

- usar archivo temporal
- usar `gh pr comment <n> --body-file <archivo>`

Evitar quoting frágil en línea que pueda romperse con backticks, comillas o escapes.

### Integration branch rule

Todos los PR autónomos de este repositorio deben apuntar a `dev`.

`main` no es base válida para PRs autónomos.

### Commit granularity rule

Usar un commit por archivo modificado cuando el cambio esté dividido por unidades documentales claras.

### Execution mode rule

Si una autorización explícita cubre toda la secuencia, el agente debe completar toda la tarea en una sola corrida y reportar solo al final, salvo bloqueo real.

