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
    ok: true,
    status: 200,
    json: () => Promise.resolve(data),
  } as any);
}

afterEach(() => {
  mockedFetch.mockReset();
  delete process.env.BOT_JWT;
  jest.restoreAllMocks();
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

test('errors are thrown for non-ok responses', async () => {
  const jsonMock = jest.fn();
  jest.spyOn(console, 'error').mockImplementation(() => {});
  mockedFetch.mockResolvedValue(
    Promise.resolve({ ok: false, status: 500, json: jsonMock } as any)
  );
  await expect(getUserLevel('tok')).rejects.toThrow('500');
  expect(jsonMock).not.toHaveBeenCalled();
});
