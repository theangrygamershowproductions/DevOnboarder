import fetch from 'node-fetch';

const baseUrl = process.env.API_BASE_URL || 'http://localhost:8001';

function buildHeaders(token?: string) {
  const headers: Record<string, string> = {};
  const jwt = token ?? process.env.BOT_JWT;
  if (jwt) {
    headers['Authorization'] = `Bearer ${jwt}`;
  }
  return headers;
}

async function request<T>(path: string, token?: string): Promise<T> {
  const resp = await fetch(`${baseUrl}${path}`, {
    headers: buildHeaders(token),
  });
  if (!resp.ok) {
    console.error(`API request to ${path} failed: ${resp.status}`);
    throw new Error(`Request failed with status ${resp.status}`);
  }
  return (await resp.json()) as T;
}

export async function getUserLevel(token?: string): Promise<number> {
  const data = await request<{ level: number }>('/api/user/level', token);
  return data.level;
}

export async function getUserContributions(token?: string): Promise<string[]> {
  const data = await request<{ contributions: string[] }>('/api/user/contributions', token);
  return data.contributions;
}

export async function getOnboardingStatus(token?: string): Promise<string> {
  const data = await request<{ status: string }>('/api/user/onboarding-status', token);
  return data.status;
}
