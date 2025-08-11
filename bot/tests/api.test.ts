import {
    getUserLevel,
    getUserContributions,
    getOnboardingStatus,
} from "../src/api";
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
    delete process.env.API_BASE_URL;
    jest.restoreAllMocks();
});

test("getUserLevel sends auth header and username", async () => {
    mockedFetch.mockResolvedValue(mockResponse({ level: 3 }));
    const level = await getUserLevel("alice", "tok");
    expect(mockedFetch).toHaveBeenCalledWith(
        expect.stringContaining("/api/user/level?username=alice"),
        expect.objectContaining({ headers: { Authorization: "Bearer tok" } }),
    );
    expect(level).toBe(3);
});

test("getUserContributions sends auth header and username", async () => {
    mockedFetch.mockResolvedValue(mockResponse({ contributions: ["fix1"] }));
    const contribs = await getUserContributions("bob", "tok");
    expect(mockedFetch).toHaveBeenCalledWith(
        expect.stringContaining("/api/user/contributions?username=bob"),
        expect.objectContaining({ headers: { Authorization: "Bearer tok" } }),
    );
    expect(contribs).toEqual(["fix1"]);
});

test("getOnboardingStatus sends auth header and username", async () => {
    mockedFetch.mockResolvedValue(mockResponse({ status: "complete" }));
    const status = await getOnboardingStatus("charlie", "tok");
    expect(mockedFetch).toHaveBeenCalledWith(
        expect.stringContaining("/api/user/onboarding-status?username=charlie"),
        expect.objectContaining({ headers: { Authorization: "Bearer tok" } }),
    );
    expect(status).toBe("complete");
});

test("token is read from BOT_JWT env var", async () => {
    mockedFetch.mockResolvedValue(mockResponse({ status: "ok" }));
    process.env.BOT_JWT = "envtoken";
    await getOnboardingStatus("dave");
    expect(mockedFetch).toHaveBeenCalledWith(
        expect.stringContaining("/api/user/onboarding-status?username=dave"),
        expect.objectContaining({
            headers: { Authorization: "Bearer envtoken" },
        }),
    );
});

test("no auth header when no token provided", async () => {
    mockedFetch.mockResolvedValue(mockResponse({ level: 1 }));
    await getUserLevel("harry");
    expect(mockedFetch).toHaveBeenCalledWith(
        expect.stringContaining("/api/user/level?username=harry"),
        expect.objectContaining({ headers: {} }),
    );
});

test("errors are thrown for non-ok responses", async () => {
    const jsonMock = jest.fn();
    jest.spyOn(console, "error").mockImplementation(() => {});
    mockedFetch.mockResolvedValue(
        Promise.resolve({ ok: false, status: 500, json: jsonMock } as any),
    );
    await expect(getUserLevel("erin", "tok")).rejects.toThrow("500");
    expect(jsonMock).not.toHaveBeenCalled();
});

test("network errors are logged and rethrown", async () => {
    const error = new Error("conn reset");
    const consoleSpy = jest
        .spyOn(console, "error")
        .mockImplementation(() => {});
    mockedFetch.mockRejectedValue(error);
    await expect(getUserLevel("frank", "tok")).rejects.toThrow(
        "Network error while requesting /api/user/level?username=frank",
    );
    expect(consoleSpy).toHaveBeenCalledWith(
        "Network error while requesting /api/user/level?username=frank:",
        error,
    );
});

test("uses default baseUrl when API_BASE_URL is not set", async () => {
    // Mock the module to test the fallback behavior
    jest.resetModules(); // Clear module cache
    const originalEnv = process.env.API_BASE_URL;
    delete process.env.API_BASE_URL;

    // Re-import the module so it re-evaluates the baseUrl constant
    const { getUserLevel: freshGetUserLevel } = require("../src/api");

    mockedFetch.mockResolvedValue(mockResponse({ level: 2 }));
    await freshGetUserLevel("defaultUser", "tok");

    expect(mockedFetch).toHaveBeenCalledWith(
        "http://localhost:8001/api/user/level?username=defaultUser",
        expect.objectContaining({ headers: { Authorization: "Bearer tok" } }),
    );

    // Restore original environment
    if (originalEnv) {
        process.env.API_BASE_URL = originalEnv;
    }
});

test("uses custom baseUrl when API_BASE_URL is set", async () => {
    // Mock the module to test custom baseUrl behavior
    jest.resetModules(); // Clear module cache
    const originalEnv = process.env.API_BASE_URL;
    process.env.API_BASE_URL = "https://custom-api.example.com";

    // Re-import the module so it re-evaluates the baseUrl constant
    const { getUserLevel: customGetUserLevel } = require("../src/api");

    mockedFetch.mockResolvedValue(mockResponse({ level: 4 }));
    await customGetUserLevel("customUser", "tok");

    expect(mockedFetch).toHaveBeenCalledWith(
        "https://custom-api.example.com/api/user/level?username=customUser",
        expect.objectContaining({ headers: { Authorization: "Bearer tok" } }),
    );

    // Restore original environment
    if (originalEnv) {
        process.env.API_BASE_URL = originalEnv;
    } else {
        delete process.env.API_BASE_URL;
    }
});
