import fetch from 'node-fetch';

const baseUrl = process.env.API_BASE_URL || 'http://localhost:8001';

export async function getUserLevel(): Promise<number> {
  const resp = await fetch(`${baseUrl}/api/user/level`);
  const data = (await resp.json()) as { level: number };
  return data.level;
}

export async function getUserContributions(): Promise<string[]> {
  const resp = await fetch(`${baseUrl}/api/user/contributions`);
  const data = (await resp.json()) as { contributions: string[] };
  return data.contributions;
}

export async function getOnboardingStatus(): Promise<string> {
  const resp = await fetch(`${baseUrl}/api/user/onboarding-status`);
  const data = (await resp.json()) as { status: string };
  return data.status;
}
