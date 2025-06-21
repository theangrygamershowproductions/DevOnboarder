import {
  getUserLevel,
  getUserContributions,
  getOnboardingStatus,
} from '../src/api';
import fetch from 'node-fetch';

jest.mock('node-fetch');
const mockedFetch = fetch as jest.MockedFunction<typeof fetch>;

function mockResponse(data: unknown) {
  return Promise.resolve({
    json: () => Promise.resolve(data),
  } as any);
}

afterEach(() => {
  mockedFetch.mockReset();
  delete process.env.BOT_JWT;
});

test('getUserLevel sends auth header', async () => {
  mockedFetch.mockResolvedValue(mockResponse({ level: 3 }));
  const level = await getUserLevel('tok');
  expect(mockedFetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/user/level'),
    expect.objectContaining({ headers: { Authorization: 'Bearer tok' } })
  );
  expect(level).toBe(3);
});

test('getUserContributions sends auth header', async () => {
  mockedFetch.mockResolvedValue(mockResponse({ contributions: ['fix1'] }));
  const contribs = await getUserContributions('tok');
  expect(mockedFetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/user/contributions'),
    expect.objectContaining({ headers: { Authorization: 'Bearer tok' } })
  );
  expect(contribs).toEqual(['fix1']);
});

test('getOnboardingStatus sends auth header', async () => {
  mockedFetch.mockResolvedValue(mockResponse({ status: 'complete' }));
  const status = await getOnboardingStatus('tok');
  expect(mockedFetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/user/onboarding-status'),
    expect.objectContaining({ headers: { Authorization: 'Bearer tok' } })
  );
  expect(status).toBe('complete');
});

test('token is read from BOT_JWT env var', async () => {
  mockedFetch.mockResolvedValue(mockResponse({ status: 'ok' }));
  process.env.BOT_JWT = 'envtoken';
  await getOnboardingStatus();
  expect(mockedFetch).toHaveBeenCalledWith(
    expect.any(String),
    expect.objectContaining({ headers: { Authorization: 'Bearer envtoken' } })
  );
});
