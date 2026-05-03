// rate-limiter.js
//
// Simple in-process rate limiter for webhook events.
// Enforces a per-repo sliding window limit (default 10 events/minute).
// Not durable: restarts reset counters. Good enough for 1.0.0 given
// webhooks are low-volume and Tailscale-scoped.

'use strict';

const WINDOW_MS = 60_000;

function createRateLimiter({ maxPerWindow = 10 } = {}) {
  const buckets = new Map(); // key -> array of timestamps (ms)

  function prune(key, now) {
    const arr = buckets.get(key);
    if (!arr) return;
    const cutoff = now - WINDOW_MS;
    let i = 0;
    while (i < arr.length && arr[i] < cutoff) i++;
    if (i > 0) arr.splice(0, i);
    if (arr.length === 0) buckets.delete(key);
  }

  function tryAcquire(key) {
    const now = Date.now();
    prune(key, now);
    const arr = buckets.get(key) || [];
    if (arr.length >= maxPerWindow) {
      return { allowed: false, retryAfterMs: WINDOW_MS - (now - arr[0]) };
    }
    arr.push(now);
    buckets.set(key, arr);
    return { allowed: true, retryAfterMs: 0 };
  }

  return { tryAcquire };
}

module.exports = { createRateLimiter };
