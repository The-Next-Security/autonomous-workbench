# Webhooks GitHub — recepción segura

Componente que recibe webhooks de GitHub y los loguea para inspección
posterior. Alcance de 1.0.0 es **solo recepción segura**: validación de
origen y firma, rate limiting, logging. La automatización de respuesta
(auto-review, auto-triage, disparo de flujos) queda para iteraciones 1.x.

## Arquitectura

```
GitHub Cloud ---> Tailscale ---> VPS:18910 (loopback) ---> github-handler.js
                                                              |
                                                              v
                                              ~/.openclaw/logs/webhooks/events-<fecha>.jsonl
```

- Binding: `127.0.0.1:18910` (loopback).
- Exposición externa: solo vía Tailscale o túnel SSH. Nunca puerto abierto en internet.
- Shared secret: configurado fuera del repo, cargado por systemd.

## Componentes

- `infra/webhooks/github-handler.js` — endpoint HTTP, acepta
  `POST /webhooks/github`.
- `infra/webhooks/signature-validator.js` — HMAC SHA-256 timing-safe.
- `infra/webhooks/origin-guard.js` — allowlist CIDR (Tailscale).
- `infra/webhooks/rate-limiter.js` — ventana deslizante por repo, default
  10 events/min.
- `infra/webhooks/systemd/webhook-receiver.service` — unit user para
  correr el handler como daemon.

Ningún framework. Sólo módulos builtin de Node.js 22+.

## Variables de entorno

| Variable | Default | Descripción |
|----------|---------|-------------|
| `WEBHOOK_PORT` | 18910 | Puerto de escucha |
| `WEBHOOK_BIND` | 127.0.0.1 | Dirección de binding |
| `WEBHOOK_SECRET` | (ninguno) | HMAC shared secret. Requerido para arrancar |
| `WEBHOOK_ALLOW_CIDRS` | 127.0.0.0/8,::1/128 | CIDRs permitidas como origen |
| `WEBHOOK_LOG_DIR` | ~/.openclaw/logs/webhooks | Directorio de logs |
| `WEBHOOK_MAX_PER_MINUTE` | 10 | Events/min por repo |

## Setup (manual, una vez)

Crear el archivo de entorno fuera del repo:

```
mkdir -p /root/.keys
cat > /root/.keys/webhook-receiver.env <<'EOF'
WEBHOOK_SECRET=<valor generado: openssl rand -hex 32>
WEBHOOK_ALLOW_CIDRS=100.64.0.0/10
EOF
chmod 600 /root/.keys/webhook-receiver.env
```

Instalar la unit de systemd:

```
mkdir -p ~/.config/systemd/user/
cp /opt/tns-workbench/autonomous-workbench/infra/webhooks/systemd/webhook-receiver.service \
   ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now webhook-receiver
systemctl --user status webhook-receiver
```

## Configuración en GitHub

En cada repo donde se quiera recibir eventos:

1. Settings -> Webhooks -> Add webhook.
2. Payload URL: `http://<tailscale-host>:18910/webhooks/github` (o vía
   reverse proxy si se prefiere).
3. Content type: `application/json`.
4. Secret: el mismo valor que en `WEBHOOK_SECRET`.
5. Events: seleccionar los relevantes (pull_request, issues,
   push, issue_comment inicialmente).
6. Active: on.

## Formato de log

Cada evento recibido o rechazado genera una línea JSON en
`events-YYYY-MM-DD.jsonl`:

```json
{"ts":"2026-04-25T10:00:00Z","outcome":"accepted","remote":"100.64.1.2","repo":"The-Next-Security/autonomous-workbench","event":"pull_request","delivery":"abc-123"}
```

Campos `outcome` posibles:
- `accepted`: firma válida, origen permitido, dentro del rate limit.
- `rejected-origin`: origen fuera de los CIDRs permitidos (403).
- `rejected-signature`: firma inválida (401).
- `rejected-parse`: cuerpo no es JSON válido (400).
- `rate-limited`: se excedió el límite del repo (429).

## Gate de aceptación del PR

- Unit de systemd corre sin error tras habilitar.
- `curl` con firma válida desde loopback devuelve 202.
- `curl` con firma inválida devuelve 401.
- `curl` con origen no permitido (simulado con binding público
  temporal + IP distinta) devuelve 403.
- Los logs quedan en `~/.openclaw/logs/webhooks/events-<fecha>.jsonl`.

## Fuera de alcance de 1.0.0

- Automatización de respuestas (auto-review, auto-triage, disparo de
  flujos autónomos a partir del evento).
- Verificación adicional por lista de repos permitidos (se puede agregar
  en iteraciones futuras leyendo una config).
- Cola durable (1.0.0 procesa en memoria; rate-limiter es in-process).
- UI de consulta de eventos.

Estos puntos están documentados como backlog 1.x.
