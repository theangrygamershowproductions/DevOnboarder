// PATCHED v0.1.0 auth-server/tests/auth_logout.spec.ts — logout revokes token
import request from 'supertest';
import { beforeAll, test, expect } from 'vitest';

process.env.JWT_SECRET = 'testsecret';
process.env.JWT_ISSUER = 'urn:test';
process.env.JWT_AUDIENCE = 'urn:dev';

let app: ReturnType<typeof import('../src/index').createApp>;

beforeAll(async () => {
  const mod = await import('../src/index');
  app = mod.createApp();
});

test('logout invalidates JWT', async () => {
  const loginRes = await request(app)
    .post('/api/auth/login')
    .type('form')
    .send({ username: 'demo', password: 'password' });
  expect(loginRes.status).toBe(200);
  const token = loginRes.body.access_token;

  const res1 = await request(app)
    .get('/api/auth/user')
    .set('Authorization', `Bearer ${token}`);
  expect(res1.status).toBe(200);

  const logoutRes = await request(app)
    .post('/api/auth/logout')
    .set('Authorization', `Bearer ${token}`);
  expect(logoutRes.status).toBe(200);

  const res2 = await request(app)
    .get('/api/auth/user')
    .set('Authorization', `Bearer ${token}`);
  expect(res2.status).toBe(401);
});
