import { describe, it, expect, vi } from "vitest";
import { retryOperation, retryFetch, RetryOptions } from "../../utils/retry";

// Mock fetch for retryFetch tests
global.fetch = vi.fn();

describe("Retry Utilities", () => {
    beforeEach(() => {
        vi.clearAllMocks();
        vi.clearAllTimers();
        vi.useFakeTimers();
    });

    afterEach(() => {
        vi.useRealTimers();
    });

    describe("retryOperation", () => {
        it("succeeds on first attempt", async () => {
            const operation = vi.fn().mockResolvedValue("success");
            const options: RetryOptions = { maxAttempts: 3, delay: 100 };

            const result = await retryOperation(operation, options);

            expect(result).toBe("success");
            expect(operation).toHaveBeenCalledTimes(1);
        });

        it("succeeds on second attempt with delay", async () => {
            const operation = vi.fn()
                .mockRejectedValueOnce(new Error("First failure"))
                .mockResolvedValueOnce("success");
            const options: RetryOptions = { maxAttempts: 3, delay: 100 };

            const promise = retryOperation(operation, options);

            // Fast-forward through the delay
            await vi.runAllTimersAsync();

            const result = await promise;

            expect(result).toBe("success");
            expect(operation).toHaveBeenCalledTimes(2);
        });

        it("fails after max attempts", async () => {
            const operation = vi.fn().mockRejectedValue(new Error("Persistent failure"));
            const options: RetryOptions = { maxAttempts: 2, delay: 100 };

            const promise = retryOperation(operation, options);

            // Fast-forward through all delays
            await vi.runAllTimersAsync();

            await expect(promise).rejects.toThrow("Operation failed after 2 attempts: Persistent failure");
            expect(operation).toHaveBeenCalledTimes(2);
        });

        it("applies backoff factor correctly", async () => {
            const operation = vi.fn()
                .mockRejectedValueOnce(new Error("First failure"))
                .mockRejectedValueOnce(new Error("Second failure"))
                .mockResolvedValueOnce("success");
            const options: RetryOptions = { maxAttempts: 3, delay: 100, backoffFactor: 2 };

            const promise = retryOperation(operation, options);

            // Fast-forward through all delays
            await vi.runAllTimersAsync();

            const result = await promise;

            expect(result).toBe("success");
            expect(operation).toHaveBeenCalledTimes(3);
        });
    });

    describe("retryFetch", () => {
        it("succeeds on first attempt", async () => {
            const mockResponse = new Response("success", { status: 200 });
            (fetch as any).mockResolvedValue(mockResponse);

            const result = await retryFetch("https://api.example.com/test");

            expect(result).toBe(mockResponse);
            expect(fetch).toHaveBeenCalledTimes(1);
            expect(fetch).toHaveBeenCalledWith("https://api.example.com/test", undefined);
        });

        it("retries on HTTP error", async () => {
            const errorResponse = new Response("Error", { status: 500 });
            const successResponse = new Response("success", { status: 200 });
            (fetch as any)
                .mockResolvedValueOnce(errorResponse)
                .mockResolvedValueOnce(successResponse);

            const promise = retryFetch("https://api.example.com/test");

            // Fast-forward through delays
            await vi.runAllTimersAsync();

            const result = await promise;

            expect(result).toBe(successResponse);
            expect(fetch).toHaveBeenCalledTimes(2);
        });

        it("fails after max retries", async () => {
            const errorResponse = new Response("Error", { status: 500, statusText: "Internal Server Error" });
            (fetch as any).mockResolvedValue(errorResponse);

            const promise = retryFetch("https://api.example.com/test", undefined, { maxAttempts: 2, delay: 100 });

            // Fast-forward through all delays
            await vi.runAllTimersAsync();

            await expect(promise).rejects.toThrow("Operation failed after 2 attempts: HTTP 500: Internal Server Error");
            expect(fetch).toHaveBeenCalledTimes(2);
        });

        it("passes request options to fetch", async () => {
            const mockResponse = new Response("success", { status: 200 });
            (fetch as any).mockResolvedValue(mockResponse);

            const requestOptions: RequestInit = {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ data: "test" })
            };

            await retryFetch("https://api.example.com/test", requestOptions);

            expect(fetch).toHaveBeenCalledWith("https://api.example.com/test", requestOptions);
        });
    });
});
