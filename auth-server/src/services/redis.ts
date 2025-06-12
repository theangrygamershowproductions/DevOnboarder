// PATCHED v0.1.2 auth-server/src/services/redis.ts — use ioredis with optional mock
import Redis from 'ioredis';

const memorySet = new Set<string>();

const url = process.env.REDIS_URL || 'redis://localhost:6379/0';

let client: any;
if (process.env.REDIS_MOCK === '1') {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const RedisMock = require('ioredis-mock');
  client = new RedisMock(url);
} else {
  client = new Redis(url);
}

if (!client.setEx && typeof client.setex === 'function') {
  client.setEx = client.setex.bind(client);
}

client.isReady = false;
client.on('ready', () => {
  client.isReady = true;
});
client.on('end', () => {
  client.isReady = false;
});

export const redisClient = client as Redis & { isReady: boolean };

export default redisClient;

export function memoryAdd(key: string, ttl: number) {
  memorySet.add(key);
  setTimeout(() => memorySet.delete(key), ttl * 1000).unref();
}

export function memoryGet(key: string): boolean {
  return memorySet.has(key);
}
