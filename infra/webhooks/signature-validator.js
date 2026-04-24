// signature-validator.js
//
// HMAC SHA-256 validation for GitHub webhook payloads.
// GitHub sends the signature in the `X-Hub-Signature-256` header in the
// form `sha256=<hex>`. We compute the expected signature using the
// shared secret and compare in constant time.

'use strict';

const crypto = require('node:crypto');

function validateSignature(rawBody, header, secret) {
  if (!header || typeof header !== 'string' || !header.startsWith('sha256=')) {
    return { valid: false, reason: 'missing or malformed signature header' };
  }
  if (!secret) {
    return { valid: false, reason: 'webhook secret not configured' };
  }
  const received = Buffer.from(header.slice('sha256='.length), 'hex');
  const computed = crypto
    .createHmac('sha256', secret)
    .update(rawBody)
    .digest();

  if (received.length !== computed.length) {
    return { valid: false, reason: 'signature length mismatch' };
  }

  const equal = crypto.timingSafeEqual(received, computed);
  return equal
    ? { valid: true, reason: null }
    : { valid: false, reason: 'signature mismatch' };
}

module.exports = { validateSignature };
