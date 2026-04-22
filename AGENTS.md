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


### 2.6 Una branch y worktree por tarea
- Cada tarea nueva debe ejecutarse en una branch nueva
- Cada tarea nueva debe usar una worktree nueva cuando aplique
- No reutilizar una branch que ya tenga un PR abierto

### 2.7 Shell seguro para trazabilidad
- Evitar backticks en comandos shell que construyan comentarios para GitHub
- Preferir texto plano o body-file cuando se publiquen comentarios largos
- Si un comentario puede romper quoting, escalar o usar un método más seguro

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

