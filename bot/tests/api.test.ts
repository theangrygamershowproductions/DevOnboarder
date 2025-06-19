import { getUserLevel, getUserContributions, getOnboardingStatus } from '../src/api';
import fetch from 'node-fetch';

jest.mock('node-fetch');
const mockedFetch = fetch as jest.MockedFunction<typeof fetch>;

function mockResponse(data: unknown) {
  return Promise.resolve({
    json: () => Promise.resolve(data)
  } as any);
}

test('getUserLevel returns level from API', async () => {
  mockedFetch.mockImplementation(() => mockResponse({ level: 3 }));
  const level = await getUserLevel();
  expect(mockedFetch).toHaveBeenCalledWith(expect.stringContaining('/api/user/level'));
  expect(level).toBe(3);
});

test('getUserContributions returns contributions from API', async () => {
  mockedFetch.mockImplementation(() => mockResponse({ contributions: ['fix1'] }));
  const contribs = await getUserContributions();
  expect(mockedFetch).toHaveBeenCalledWith(expect.stringContaining('/api/user/contributions'));
  expect(contribs).toEqual(['fix1']);
});

test('getOnboardingStatus returns status from API', async () => {
  mockedFetch.mockImplementation(() => mockResponse({ status: 'complete' }));
  const status = await getOnboardingStatus();
  expect(mockedFetch).toHaveBeenCalledWith(expect.stringContaining('/api/user/onboarding-status'));
  expect(status).toBe('complete');
});
