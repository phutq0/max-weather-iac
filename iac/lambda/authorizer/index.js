import fetch from 'node-fetch';
import { createRemoteJWKSet, jwtVerify } from 'jose';
import LRUCache from 'lru-cache';

const {
  OAUTH_ISSUER,
  OAUTH_AUDIENCE,
  OAUTH_INTROSPECTION_URL,
  OAUTH_CLIENT_ID,
  OAUTH_CLIENT_SECRET,
  CACHE_TTL_SECONDS = '300'
} = process.env;

const tokenCache = new LRUCache({ max: 1000, ttl: parseInt(CACHE_TTL_SECONDS, 10) * 1000 });
let jwks;

function buildPolicy(effect, principalId, resource, context = {}) {
  return {
    principalId: principalId || 'user',
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: resource,
        },
      ],
    },
    context,
  };
}

async function verifyJwt(token) {
  if (!jwks) {
    jwks = createRemoteJWKSet(new URL(`${OAUTH_ISSUER}/.well-known/jwks.json`));
  }
  const { payload } = await jwtVerify(token, jwks, {
    issuer: OAUTH_ISSUER,
    audience: OAUTH_AUDIENCE,
  });
  return payload;
}

async function introspectToken(token) {
  if (!OAUTH_INTROSPECTION_URL) return null;
  const res = await fetch(OAUTH_INTROSPECTION_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Basic ' + Buffer.from(`${OAUTH_CLIENT_ID}:${OAUTH_CLIENT_SECRET}`).toString('base64')
    },
    body: new URLSearchParams({ token }),
  });
  if (!res.ok) throw new Error(`Introspection failed: ${res.status}`);
  return res.json();
}

export const handler = async (event) => {
  try {
    const token = (event.authorizationToken || '').replace(/^Bearer\s+/i, '');
    if (!token) {
      return buildPolicy('Deny', 'anonymous', event.methodArn);
    }

    const cached = tokenCache.get(token);
    if (cached) {
      return buildPolicy('Allow', cached.sub || 'user', event.methodArn, { sub: cached.sub || '' });
    }

    let payload;
    try {
      payload = await verifyJwt(token);
    } catch (e) {
      const introspection = await introspectToken(token);
      if (!introspection || !introspection.active) {
        return buildPolicy('Deny', 'invalid', event.methodArn);
      }
      payload = { sub: introspection.sub, scope: introspection.scope };
    }

    tokenCache.set(token, payload);
    return buildPolicy('Allow', payload.sub || 'user', event.methodArn, { sub: payload.sub || '', scope: (payload.scope || '') });
  } catch (err) {
    console.error('Auth error', err);
    return buildPolicy('Deny', 'error', event.methodArn);
  }
};

