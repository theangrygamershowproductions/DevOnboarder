export interface RetryOptions {
    maxAttempts: number;
    delay: number;
    backoffFactor?: number;
}

export async function retryOperation<T>(
    operation: () => Promise<T>,
    options: RetryOptions
): Promise<T> {
    const { maxAttempts, delay, backoffFactor = 1.5 } = options;
    let lastError: Error;

    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
            return await operation();
        } catch (error) {
            lastError = error as Error;

            if (attempt === maxAttempts) {
                throw new Error(`Operation failed after ${maxAttempts} attempts: ${lastError.message}`);
            }

            const currentDelay = delay * Math.pow(backoffFactor, attempt - 1);
            await new Promise(resolve => setTimeout(resolve, currentDelay));
        }
    }

    throw lastError!;
}

export async function retryFetch(
    url: string,
    options?: RequestInit,
    retryOptions: RetryOptions = { maxAttempts: 3, delay: 1000 }
): Promise<Response> {
    return retryOperation(async () => {
        const response = await fetch(url, options);

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        return response;
    }, retryOptions);
}
