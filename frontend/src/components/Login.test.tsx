import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { vi } from 'vitest';
import Login from './Login';

describe('Login component', () => {
  it('shows discord link when no token exists', () => {
    // Ensure local storage is empty
    localStorage.removeItem('jwt');
    // Provide the auth URL expected by the component
    vi.stubEnv('VITE_AUTH_URL', 'http://localhost');

    render(<Login />);

    const link = screen.getByRole('link', { name: /log in with discord/i });
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute('href', 'http://localhost/login/discord');
    vi.unstubAllEnvs();
  });
});
