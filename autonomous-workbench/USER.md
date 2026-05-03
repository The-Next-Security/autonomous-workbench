# USER.md — Humanos y organización TNS

## Aprobadores de merges a main (GitHub)

La autorización de merges hacia `main` se gestiona exclusivamente por
GitHub mediante branch protection. Los usuarios autorizados para
aprobar merges a `main` en los 3 repos del sistema son:

- `felipecleverox`
- `Bufigol`
- `TNSTRACK`
- `andresTNS`

Roy no aprueba ni ejecuta merges a `main` bajo ninguna circunstancia.
La única ruta válida hacia `main` es un release con aprobación humana
vía PR desde `dev`.

## Persona principal de interacción

- **Nombre:** Felipe Vásquez
- **Cómo dirigirse a él:** Felipe
- **Rol:** CEO de The Next Security (TNS) y Cleverox
- **Idioma preferido:** español
- **Canal primario:** Telegram (`@asistente_tns_bot`, chatID `6739292510`)
- **GitHub:** `anibalTNS` como cuenta operativa del bot
- **Email:** `felipe@thenextsecurity.cl`
- **VPS del sistema:** Contabo `207.180.249.180`

Felipe es la persona principal con la que el sistema se comunica. Llega
a Roy únicamente a través de Aníbal (nunca directo). Decisiones de
negocio, gasto y publicación externa escalan a Felipe.

## Organización y otros colaboradores humanos

Otros miembros de la organización TNS (incluidos los aprobadores
listados arriba) pueden leer issues y PRs, dejar comentarios, aprobar
o rechazar. El sistema responde a comentarios de PRs y a menciones en
issues con el mismo nivel de formalidad que con Felipe.

## Disciplina de pull frecuente

Cada usuario trabaja idealmente en su propia branch, pero `dev` es la
base común y puede avanzar en paralelo por contribuciones humanas o
autónomas. Antes de iniciar cualquier trabajo:

- `git fetch origin` en el repo correspondiente.
- `git pull --ff-only` en la branch activa si se trabaja sobre `dev`
  u otra de integración.
- Al retomar una `feature/*` propia que estaba pausada, verificar si
  `dev` avanzó y rebasar si aplica.

Roy y los especialistas siguen el mismo protocolo antes de cualquier
operación sobre archivos tracked.

## Contexto de la organización TNS

TNS (The Next Security) es una **empresa de desarrollo**. Construye
soluciones de software — no es una empresa de seguridad informática
en el sentido de consultoría de pentesting. El nombre histórico
incluye "Security" pero el negocio actual es desarrollo de productos
y servicios de software.

Cleverox es una marca y/o vertical de TNS también operada por Felipe.

## Propósito del sistema autónomo

Este sistema es un **framework** que permite a OpenClaw trabajar de
forma autónoma dentro de repositorios arbitrarios que la organización
le indique vía Telegram. El operador humano pide por Telegram (a
Aníbal) que el sistema abra y trabaje dentro de la carpeta de un
repositorio: Aníbal coordina con Roy, Roy orquesta al equipo de
especialistas, todos siguiendo las directrices, workflows, agentes y
skills descritos en este corredor.

En 1.0.0 el sistema se valida sobre los 3 repos base del sistema
mismo (ver abajo). Una vez estabilizado, la infraestructura está
pensada para abrir y trabajar en cualquier otro repositorio de la
organización (o de sus clientes con autorización explícita).

## Sistema interno sincronizado con GitHub

El sistema mantiene estado interno (runtime en `/root/.openclaw/`,
motor Scrum en `scrum-files`, skills en `agents-files`)
**sincronizado con GitHub**. GitHub es la fuente de verdad pública y
auditable; el estado interno es la copia operativa que el runtime
consume.

Reglas derivadas:
- Todo cambio importante queda trazado en GitHub (issue, PR,
  comentario, commit).
- Los instaladores idempotentes (`install-agents.sh`,
  `install-crons.sh`) reconcilian el estado local con los templates
  del repo sin destruir personalización.
- El sistema es robusto ante desincronización temporal: si la
  conexión GitHub cae, puede seguir operando con el estado local
  hasta que vuelva y reconciliar después.

## Repositorios base del sistema

Los siguientes **tres repositorios son la base del sistema autónomo**.
No son los únicos repos que el sistema podrá trabajar en el futuro,
pero son los que lo constituyen a sí mismo:

- `autonomous-workbench` — corredor de ejecución, Roy (Scrum Master),
  documentación principal, scripts de infra.
- `scrum-files` — motor Scrum (`sprint-manager.js`, `product-backlog`,
  `sprint-state`, histórico de sprints).
- `agents-files` — skills de los roles Scrum, governance-wrapper,
  coding-agent y demás skills de soporte.

El objetivo de 1.0.0 es que estos 3 repos queden estables, validados y
productivos. Iteraciones posteriores extenderán el sistema para operar
autónomamente sobre repositorios adicionales (productos de TNS, demos,
clientes, etc.) siempre bajo autorización explícita.

Queda fuera de alcance de 1.0.0: `TNS_TRACK_DEMO` y cualquier repo de
cliente. Se utilizarán como consumidores del sistema una vez
estabilizado.

## Preferencias operativas transversales

- Respuestas concisas y estructuradas, sin infodumps.
- Sin emojis en archivos ni comunicación.
- Decisiones presentadas con recomendación por defecto.
- GitHub (issues y PRs) como fuente de verdad operativa para
  discusiones técnicas; Telegram como canal de comando/alerta.
- Toda acción que afecte estado compartido deja comentario explícito
  (no hay acciones silenciosas).
