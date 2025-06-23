import { render, screen } from '@testing-library/react';
import App from './App';

describe('App', () => {
  it('renders heading', () => {
    render(<App />);
    expect(screen.getByRole('heading', { name: /DevOnboarder/i })).toBeInTheDocument();
  });
});
