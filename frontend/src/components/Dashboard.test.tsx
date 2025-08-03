import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { vi } from 'vitest';
import Dashboard from './Dashboard';

// Mock fetch
global.fetch = vi.fn();

// Mock WebSocket
global.WebSocket = vi.fn().mockImplementation(() => ({
  onopen: vi.fn(),
  onmessage: vi.fn(),
  onclose: vi.fn(),
  onerror: vi.fn(),
  close: vi.fn(),
}));

const mockScripts = [
  {
    name: 'test_script.sh',
    path: 'scripts/test_script.sh',
    description: 'A test script for CI',
    category: 'testing',
    executable: true,
    last_modified: '2025-01-13T10:00:00Z',
    size_bytes: 1024,
  },
  {
    name: 'deploy_script.py',
    path: 'scripts/deploy_script.py',
    description: 'Deployment automation script',
    category: 'deployment',
    executable: true,
    last_modified: '2025-01-13T11:00:00Z',
    size_bytes: 2048,
  },
];

const mockExecutions = [
  {
    execution_id: 'exec-1',
    script_path: 'scripts/test_script.sh',
    status: 'completed' as const,
    exit_code: 0,
    output: 'Test completed successfully',
    error: '',
    start_time: '2025-01-13T12:00:00Z',
    end_time: '2025-01-13T12:01:00Z',
    duration_seconds: 60,
  },
];

describe('Dashboard Component', () => {
  beforeEach(() => {
    vi.mocked(fetch).mockClear();
  });

  it('renders dashboard title', async () => {
    vi.mocked(fetch)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockScripts,
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockExecutions,
      } as Response);

    render(<Dashboard />);

    expect(screen.getByText('CI Troubleshooting Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Discover and execute automation scripts for DevOnboarder')).toBeInTheDocument();
  });

  it('loads and displays scripts', async () => {
    vi.mocked(fetch)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockScripts,
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockExecutions,
      } as Response);

    render(<Dashboard />);

    await waitFor(() => {
      expect(screen.getByText('test_script.sh')).toBeInTheDocument();
      expect(screen.getByText('deploy_script.py')).toBeInTheDocument();
    });

    expect(screen.getByText('A test script for CI')).toBeInTheDocument();
    expect(screen.getByText('Deployment automation script')).toBeInTheDocument();
  });

  it('filters scripts by category', async () => {
    vi.mocked(fetch)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockScripts,
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockExecutions,
      } as Response);

    render(<Dashboard />);

    await waitFor(() => {
      expect(screen.getByText('test_script.sh')).toBeInTheDocument();
    });

    const categorySelect = screen.getByDisplayValue('All Categories');
    fireEvent.change(categorySelect, { target: { value: 'testing' } });

    await waitFor(() => {
      expect(screen.getByText('test_script.sh')).toBeInTheDocument();
      expect(screen.queryByText('deploy_script.py')).not.toBeInTheDocument();
    });
  });

  it('filters scripts by search term', async () => {
    vi.mocked(fetch)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockScripts,
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockExecutions,
      } as Response);

    render(<Dashboard />);

    await waitFor(() => {
      expect(screen.getByText('test_script.sh')).toBeInTheDocument();
    });

    const searchInput = screen.getByPlaceholderText('Search scripts...');
    fireEvent.change(searchInput, { target: { value: 'deploy' } });

    await waitFor(() => {
      expect(screen.queryByText('test_script.sh')).not.toBeInTheDocument();
      expect(screen.getByText('deploy_script.py')).toBeInTheDocument();
    });
  });

  it('selects script for execution', async () => {
    vi.mocked(fetch)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockScripts,
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockExecutions,
      } as Response);

    render(<Dashboard />);

    await waitFor(() => {
      expect(screen.getByText('test_script.sh')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByText('test_script.sh'));

    await waitFor(() => {
      expect(screen.getByText('Execute Script')).toBeInTheDocument();
      expect(screen.getByDisplayValue('test_script.sh')).toBeInTheDocument();
    });
  });

  it('displays execution results', async () => {
    vi.mocked(fetch)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockScripts,
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => mockExecutions,
      } as Response);

    render(<Dashboard />);

    await waitFor(() => {
      expect(screen.getByText('Recent Executions')).toBeInTheDocument();
      expect(screen.getByText('scripts/test_script.sh')).toBeInTheDocument();
      expect(screen.getByText('completed')).toBeInTheDocument();
      expect(screen.getByText('Test completed successfully')).toBeInTheDocument();
    });
  });

  it('handles loading state', () => {
    vi.mocked(fetch)
      .mockImplementation(() => new Promise(() => {})); // Never resolves

    render(<Dashboard />);

    expect(screen.getByText('Loading dashboard...')).toBeInTheDocument();
  });

  it('handles error state', async () => {
    vi.mocked(fetch)
      .mockRejectedValueOnce(new Error('Network error'));

    render(<Dashboard />);

    await waitFor(() => {
      expect(screen.getByText(/Failed to load scripts/)).toBeInTheDocument();
    });
  });
});
