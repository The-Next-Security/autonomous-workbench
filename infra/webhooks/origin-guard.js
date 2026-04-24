// origin-guard.js
//
// Validates that an incoming request arrived through an allowed origin
// (Tailscale IP). The allowlist is loaded from WEBHOOK_ALLOW_CIDRS env
// var (comma-separated CIDR blocks) and defaults to loopback only if
// not set.
//
// Uses node's builtin address utilities; no third-party deps.

'use strict';

const { isIPv4, isIPv6 } = require('node:net');

function loadCidrs() {
  const raw = process.env.WEBHOOK_ALLOW_CIDRS || '127.0.0.0/8,::1/128';
  return raw
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean)
    .map(parseCidr);
}

function parseCidr(entry) {
  const [addr, prefixStr] = entry.split('/');
  const prefix = Number(prefixStr);
  if (!Number.isInteger(prefix) || prefix < 0) {
    throw new Error(`invalid CIDR: ${entry}`);
  }
  if (isIPv4(addr)) {
    return { family: 4, addr, prefix };
  }
  if (isIPv6(addr)) {
    return { family: 6, addr, prefix };
  }
  throw new Error(`invalid CIDR (unrecognized address): ${entry}`);
}

function ipv4ToInt(ip) {
  return ip
    .split('.')
    .reduce((acc, oct) => (acc << 8) + Number(oct), 0) >>> 0;
}

function ipv4InCidr(ip, cidr) {
  const ipInt = ipv4ToInt(ip);
  const baseInt = ipv4ToInt(cidr.addr);
  if (cidr.prefix === 0) return true;
  const mask = (~0 << (32 - cidr.prefix)) >>> 0;
  return (ipInt & mask) === (baseInt & mask);
}

function ipv6Expand(ip) {
  const [head, tail] = ip.includes('::')
    ? ip.split('::').map((s) => (s === '' ? [] : s.split(':')))
    : [ip.split(':'), []];
  const missing = 8 - (head.length + tail.length);
  const full = [
    ...head,
    ...Array(missing).fill('0'),
    ...tail,
  ].map((part) => part.padStart(4, '0'));
  return full.join(':');
}

function ipv6ToBigInt(ip) {
  const full = ipv6Expand(ip);
  return full
    .split(':')
    .reduce((acc, part) => (acc << 16n) + BigInt(parseInt(part, 16)), 0n);
}

function ipv6InCidr(ip, cidr) {
  const ipInt = ipv6ToBigInt(ip);
  const baseInt = ipv6ToBigInt(cidr.addr);
  if (cidr.prefix === 0) return true;
  const mask = ((1n << 128n) - 1n) ^ ((1n << BigInt(128 - cidr.prefix)) - 1n);
  return (ipInt & mask) === (baseInt & mask);
}

function isAllowedOrigin(remoteAddress, cidrs) {
  if (!remoteAddress) return false;
  // Strip IPv4-mapped IPv6 prefix (::ffff:)
  const addr = remoteAddress.startsWith('::ffff:')
    ? remoteAddress.slice('::ffff:'.length)
    : remoteAddress;

  if (isIPv4(addr)) {
    return cidrs.filter((c) => c.family === 4).some((c) => ipv4InCidr(addr, c));
  }
  if (isIPv6(addr)) {
    return cidrs.filter((c) => c.family === 6).some((c) => ipv6InCidr(addr, c));
  }
  return false;
}

module.exports = { loadCidrs, isAllowedOrigin, parseCidr };
