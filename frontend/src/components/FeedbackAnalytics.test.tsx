import { render, screen } from '@testing-library/react';
import { vi } from 'vitest';
import FeedbackAnalytics from './FeedbackAnalytics';

const URL = 'http://feedback.example.com';

describe('FeedbackAnalytics', () => {
    beforeEach(() => {
        vi.stubEnv('VITE_FEEDBACK_URL', URL);
    });
    afterEach(() => {
        vi.unstubAllEnvs();
        vi.restoreAllMocks();
    });

    it('shows analytics summary', async () => {
        vi.stubGlobal(
            'fetch',
            vi.fn().mockResolvedValue({
                ok: true,
                json: () =>
                    Promise.resolve({
                        total: 1,
                        breakdown: { bug: { open: 1 } },
                    }),
            }),
        );

        render(<FeedbackAnalytics />);
        expect(
            await screen.findByText(/total feedback: 1/i),
        ).toBeInTheDocument();
        expect(screen.getByText(/bug/i)).toBeInTheDocument();
        expect(screen.getByText(/open: 1/i)).toBeInTheDocument();
    });
});
