import { render, screen } from '@testing-library/react';
import { vi } from 'vitest';
import App from './App';

describe('App', () => {
    beforeEach(() => {
        vi.stubEnv('VITE_FEEDBACK_URL', 'http://test');
        vi.stubGlobal(
            'fetch',
            vi.fn().mockResolvedValue({
                json: () => Promise.resolve({ feedback: [] }),
            }),
        );
    });
    afterEach(() => {
        vi.unstubAllEnvs();
        vi.restoreAllMocks();
    });

    it('renders heading', () => {
        render(<App />);
        expect(
            screen.getByRole('heading', { name: /DevOnboarder/i }),
        ).toBeInTheDocument();
    });
});
