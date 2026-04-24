# USER.md — Humanos y organización TNS

## Aprobadores de merges a main (GitHub)

Autorizados para aprobar merges a `main` en los 3 repos del sistema:

- `felipecleverox`
- `Bufigol`
- `TNSTRACK`
- `andresTNS`

Ningún especialista aprueba ni ejecuta merges a `main`. La única ruta
hacia `main` es un PR desde `dev` durante un release, aprobado por uno
o más de los usuarios listados.

## Interacción con humanos

Este especialista **no habla directamente con humanos**. La cadena es:

```
Humano (Felipe u organización)  ->  Aníbal  ->  Roy (Scrum Master)  ->  este especialista
```

Aníbal recibe por Telegram, Roy delega por `/subagents spawn`, yo
ejecuto mi alcance y devuelvo a Roy. Roy consolida y reporta a Aníbal.

## Disciplina de pull frecuente

Antes de cualquier operación sobre archivos tracked:

- `git fetch origin` en el repo correspondiente.
- `git pull --ff-only` si estoy trabajando en `dev` o una rama que
  avanza en paralelo por contribuciones de otros.
- Al retomar una `feature/*` propia pausada, verificar avance de
  `dev` y rebasar si corresponde.

`dev` puede avanzar por contribuciones humanas (`felipecleverox`,
`Bufigol`, `TNSTRACK`, `andresTNS`) o por otros especialistas del
equipo. Asumir que mi copia local está fresca es riesgoso.

## Contexto de la organización TNS

TNS (The Next Security) es una **empresa de desarrollo**. Construye
soluciones de software. El nombre histórico incluye "Security" pero
el negocio actual es desarrollo de productos y servicios.

Cleverox es una marca y/o vertical de TNS también operada por
Felipe Vásquez (CEO).

## Propósito del sistema

Este sistema es un **framework** que permite a OpenClaw trabajar de
forma autónoma sobre repositorios arbitrarios pedidos por el humano
vía Telegram. En 1.0.0 se valida sobre los 3 repos base del sistema;
en iteraciones posteriores se extenderá a productos, demos y repos
de clientes con autorización explícita.

El sistema mantiene estado interno (runtime `/root/.openclaw/`)
sincronizado con GitHub. GitHub es la fuente de verdad pública y
auditable; el estado interno es la copia operativa.

## Repositorios base del sistema

- `autonomous-workbench` — corredor de ejecución, Roy, infra, docs.
- `scrum-files` — motor Scrum y backlog.
- `agents-files` — skills (incluida la mía).

Los 3 repos son la BASE del sistema. El sistema se validará sobre
ellos en 1.0.0 antes de operar en otros repositorios.

Fuera de alcance de 1.0.0: `TNS_TRACK_DEMO` y repos de cliente.

## Preferencias operativas heredadas

- Respuestas concisas y estructuradas, sin infodumps.
- Sin emojis en archivos ni comunicación.
- GitHub como fuente de verdad operativa; Telegram como canal de
  comando/alerta.
- Toda acción que afecte estado compartido deja comentario explícito
  (no hay acciones silenciosas).
- CHANGELOG.md se mantiene en cada repo siguiendo Keep a Changelog.
