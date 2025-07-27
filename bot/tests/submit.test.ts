import { submitContribution } from '../src/api';

declare const global: any;

beforeEach(() => {
    global.fetch = jest.fn();
});

afterEach(() => {
    (global.fetch as jest.Mock).mockReset();
});

test('submitContribution posts the contribution', async () => {
    (global.fetch as jest.Mock).mockResolvedValue({ ok: true });
    await submitContribution('alice', 'improved docs', 'tok');
    expect(global.fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/user/contributions'),
        expect.objectContaining({
            method: 'POST',
            headers: expect.objectContaining({
                Authorization: 'Bearer tok',
            }),
            body: JSON.stringify({
                username: 'alice',
                description: 'improved docs',
            }),
        }),
    );
});

test('submitContribution throws on failure', async () => {
    (global.fetch as jest.Mock).mockResolvedValue({ ok: false, status: 500 });
    await expect(submitContribution('bob', 'x', 'tok')).rejects.toThrow('500');
});
