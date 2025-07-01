
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
  let resp;
  try {
    resp = await fetch(`${baseUrl}${path}`, {
      headers: buildHeaders(token),
    });
  } catch (err) {
    console.error(`Network error while requesting ${path}:`, err);
    throw new Error(`Network error while requesting ${path}`);
  }
  if (!resp.ok) {
    console.error(`API request to ${path} failed: ${resp.status}`);
    throw new Error(`Request failed with status ${resp.status}`);
  }
  return (await resp.json()) as T;
}

export async function getUserLevel(
  username: string,
  token?: string
): Promise<number> {
  const data = await request<{ level: number }>(
    `/api/user/level?username=${encodeURIComponent(username)}`,
    token
  );
  return data.level;
}

export async function getUserContributions(
  username: string,
  token?: string
): Promise<string[]> {
  const data = await request<{ contributions: string[] }>(
    `/api/user/contributions?username=${encodeURIComponent(username)}`,
    token
  );
  return data.contributions;
}

export async function getOnboardingStatus(
  username: string,
  token?: string
): Promise<string> {
  const data = await request<{ status: string }>(
    `/api/user/onboarding-status?username=${encodeURIComponent(username)}`,
    token
  );
  return data.status;
}

export async function submitContribution(
  username: string,
  description: string,
  token?: string
): Promise<void> {
  const path = '/api/user/contributions';
  const resp = await fetch(`${baseUrl}${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...buildHeaders(token),
    },
    body: JSON.stringify({ username, description }),
  });
  if (!resp.ok) {
    console.error(`API request to ${path} failed: ${resp.status}`);
    throw new Error(`Request failed with status ${resp.status}`);
  }
}
