import {
  getUserLevel,
  getUserContributions,
  getOnboardingStatus,
} from '../src/api';
const originalFetch = global.fetch;
const mockedFetch = jest.fn() as jest.MockedFunction<typeof fetch>;

beforeEach(() => {
  global.fetch = mockedFetch;
});

function mockResponse(data: unknown) {
  return Promise.resolve({
    ok: true,
    status: 200,
    json: () => Promise.resolve(data),
  } as any);
}

afterEach(() => {
  mockedFetch.mockReset();
  global.fetch = originalFetch;
  delete process.env.BOT_JWT;
  jest.restoreAllMocks();
});

test('getUserLevel sends auth header and username', async () => {
  mockedFetch.mockResolvedValue(mockResponse({ level: 3 }));
  const level = await getUserLevel('alice', 'tok');
  expect(mockedFetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/user/level?username=alice'),
    expect.objectContaining({ headers: { Authorization: 'Bearer tok' } })
  );
  expect(level).toBe(3);
});

test('getUserContributions sends auth header and username', async () => {
  mockedFetch.mockResolvedValue(mockResponse({ contributions: ['fix1'] }));
  const contribs = await getUserContributions('bob', 'tok');
  expect(mockedFetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/user/contributions?username=bob'),
    expect.objectContaining({ headers: { Authorization: 'Bearer tok' } })
  );
  expect(contribs).toEqual(['fix1']);
});

test('getOnboardingStatus sends auth header and username', async () => {
  mockedFetch.mockResolvedValue(mockResponse({ status: 'complete' }));
  const status = await getOnboardingStatus('charlie', 'tok');
  expect(mockedFetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/user/onboarding-status?username=charlie'),
    expect.objectContaining({ headers: { Authorization: 'Bearer tok' } })
  );
  expect(status).toBe('complete');
});

test('token is read from BOT_JWT env var', async () => {
  mockedFetch.mockResolvedValue(mockResponse({ status: 'ok' }));
  process.env.BOT_JWT = 'envtoken';
  await getOnboardingStatus('dave');
  expect(mockedFetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/user/onboarding-status?username=dave'),
    expect.objectContaining({ headers: { Authorization: 'Bearer envtoken' } })
  );
});

test('errors are thrown for non-ok responses', async () => {
  const jsonMock = jest.fn();
  jest.spyOn(console, 'error').mockImplementation(() => {});
  mockedFetch.mockResolvedValue(
    Promise.resolve({ ok: false, status: 500, json: jsonMock } as any)
  );
  await expect(getUserLevel('erin', 'tok')).rejects.toThrow('500');
  expect(jsonMock).not.toHaveBeenCalled();
});

test('network errors are logged and rethrown', async () => {
  const error = new Error('conn reset');
  const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
  mockedFetch.mockRejectedValue(error);
  await expect(getUserLevel('frank', 'tok')).rejects.toThrow(
    'Network error while requesting /api/user/level?username=frank'
  );
  expect(consoleSpy).toHaveBeenCalledWith(
    'Network error while requesting /api/user/level?username=frank:',
    error
  );
});
