// github-handler.js
//
// Minimal GitHub webhook receiver for 1.0.0 of the TNS autonomous
// system. Receives events securely (HMAC signature + Tailscale origin +
// per-repo rate limit), logs them, and acks. Does NOT automate any
// response; that is explicitly out of scope for 1.0.0.
//
// Environment variables:
//   WEBHOOK_PORT           Port to bind. Default 18910.
//   WEBHOOK_BIND           Bind address. Default 127.0.0.1.
//   WEBHOOK_SECRET         Shared secret for HMAC validation. Required.
//   WEBHOOK_ALLOW_CIDRS    Comma-separated allowed CIDRs. Default loopback.
//   WEBHOOK_LOG_DIR        Directory for event logs.
//                          Default: ~/.openclaw/logs/webhooks
//   WEBHOOK_MAX_PER_MINUTE Max events per repo per minute. Default 10.
//
// Exit codes: follows standard Node process semantics.

'use strict';

const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');

const { validateSignature } = require('./signature-validator');
const { loadCidrs, isAllowedOrigin } = require('./origin-guard');
const { createRateLimiter } = require('./rate-limiter');

const PORT = Number(process.env.WEBHOOK_PORT || 18910);
const BIND = process.env.WEBHOOK_BIND || '127.0.0.1';
const SECRET = process.env.WEBHOOK_SECRET || '';
const LOG_DIR =
  process.env.WEBHOOK_LOG_DIR ||
  path.join(os.homedir(), '.openclaw', 'logs', 'webhooks');
const MAX_PER_MIN = Number(process.env.WEBHOOK_MAX_PER_MINUTE || 10);

if (!SECRET) {
  console.error('[github-handler] WEBHOOK_SECRET not set; refusing to start');
  process.exit(2);
}

fs.mkdirSync(LOG_DIR, { recursive: true, mode: 0o700 });

const cidrs = loadCidrs();
const limiter = createRateLimiter({ maxPerWindow: MAX_PER_MIN });

function logEvent(obj) {
  const day = new Date().toISOString().slice(0, 10);
  const file = path.join(LOG_DIR, `events-${day}.jsonl`);
  fs.appendFileSync(file, JSON.stringify(obj) + '\n', { mode: 0o600 });
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (c) => chunks.push(c));
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

function respond(res, code, body) {
  res.statusCode = code;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(body));
}

async function handle(req, res) {
  const remote = req.socket.remoteAddress || '';
  const ts = new Date().toISOString();

  if (req.method !== 'POST' || req.url !== '/webhooks/github') {
    return respond(res, 404, { error: 'not found' });
  }

  if (!isAllowedOrigin(remote, cidrs)) {
    logEvent({ ts, outcome: 'rejected-origin', remote });
    return respond(res, 403, { error: 'origin not allowed' });
  }

  const body = await readBody(req);
  const sig = req.headers['x-hub-signature-256'];
  const result = validateSignature(body, sig, SECRET);
  if (!result.valid) {
    logEvent({ ts, outcome: 'rejected-signature', remote, reason: result.reason });
    return respond(res, 401, { error: 'invalid signature', reason: result.reason });
  }

  const event = req.headers['x-github-event'] || 'unknown';
  const delivery = req.headers['x-github-delivery'] || 'unknown';
  let payload;
  try {
    payload = JSON.parse(body.toString('utf8'));
  } catch {
    logEvent({ ts, outcome: 'rejected-parse', remote, delivery });
    return respond(res, 400, { error: 'invalid json' });
  }

  const repo = (payload.repository && payload.repository.full_name) || 'unknown';
  const limit = limiter.tryAcquire(repo);
  if (!limit.allowed) {
    logEvent({ ts, outcome: 'rate-limited', remote, repo, event, delivery });
    return respond(res, 429, { error: 'rate limited', retryAfterMs: limit.retryAfterMs });
  }

  logEvent({ ts, outcome: 'accepted', remote, repo, event, delivery });
  respond(res, 202, { ok: true, received: { event, delivery, repo } });
}

const server = http.createServer((req, res) => {
  handle(req, res).catch((err) => {
    console.error('[github-handler] unhandled error:', err);
    respond(res, 500, { error: 'internal error' });
  });
});

server.listen(PORT, BIND, () => {
  console.log(`[github-handler] listening on ${BIND}:${PORT} (log dir: ${LOG_DIR})`);
});

const shutdown = () => {
  console.log('[github-handler] shutting down');
  server.close(() => process.exit(0));
};
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
