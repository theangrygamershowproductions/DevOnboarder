// PATCHED v0.1.61 auth-server/tests/auth.spec.ts — migrate to vitest

import request from 'supertest';
import jwt from 'jsonwebtoken';
import { test, expect, beforeAll } from 'vitest';

process.env.JWT_SECRET = 'testsecret';
process.env.JWT_ISSUER = 'urn:test';
process.env.JWT_AUDIENCE = 'urn:dev';

let app: ReturnType<typeof import('../src/index').createApp>;

beforeAll(async () => {
  const mod = await import('../src/index');
  app = mod.createApp();
});

function sign(opts = {}) {
  return jwt.sign(
    { sub: '1' },
    process.env.JWT_SECRET!,
    {
      algorithm: 'HS256',
      issuer: process.env.JWT_ISSUER,
      audience: process.env.JWT_AUDIENCE,
      expiresIn: '1m',
      ...opts,
    }
  );
}

test('JWT validation rejects invalid tokens', async () => {
  let res = await request(app).get('/api/auth/user');
  expect(res.status).toBe(401);

  const badSig = jwt.sign(
    { sub: '1', iss: process.env.JWT_ISSUER, aud: process.env.JWT_AUDIENCE },
    'wrong',
    { algorithm: 'HS256', expiresIn: '1m' }
  );
  res = await request(app)
    .get('/api/auth/user')
    .set('Authorization', `Bearer ${badSig}`);
  expect(res.status).toBe(401);

  const wrongAud = sign({ audience: 'other' });
  res = await request(app)
    .get('/api/auth/user')
    .set('Authorization', `Bearer ${wrongAud}`);
  expect(res.status).toBe(401);

  const expired = sign({ expiresIn: -10 });
  res = await request(app)
    .get('/api/auth/user')
    .set('Authorization', `Bearer ${expired}`);
  expect(res.status).toBe(401);
});

test('returns user from database', async () => {
  const token = sign();
  const res = await request(app)
    .get('/api/auth/user')
    .set('Authorization', `Bearer ${token}`);
  expect(res.status).toBe(200);
  expect(res.body.user).toHaveProperty('id', '1');
  expect(res.body.user).toHaveProperty('username', 'demo');
});
