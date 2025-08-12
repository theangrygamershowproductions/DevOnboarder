import React, { useState, useEffect } from 'react';

export interface PRRoutingToggleProps {
  owner: string;
  repo: string;
  prNumber: number;
  initialRouted?: boolean;
  onToggle?: (enabled: boolean) => void;
}

export interface PRRoutingStatus {
  ok: boolean;
  enabled: boolean;
  labels: string[];
  error?: string;
}

export interface PRRoutingResponse {
  ok: boolean;
  enabled: boolean;
  message?: string;
  error?: string;
}

/**
 * PR Routing Toggle Component
 *
 * Provides a toggle switch to enable/disable Codex routing for PRs.
 * Integrates with the orchestrator backend API.
 */
export function PRRoutingToggle({
  owner,
  repo,
  prNumber,
  initialRouted = false,
  onToggle
}: PRRoutingToggleProps) {
  const [routed, setRouted] = useState(initialRouted);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Load initial routing status
  useEffect(() => {
    const loadRoutingStatus = async () => {
      try {
        setLoading(true);
        const response = await fetch(`/api/pr/${owner}/${repo}/${prNumber}/route`);
        const data: PRRoutingStatus = await response.json();

        if (data.ok) {
          setRouted(data.enabled);
        } else {
          setError(data.error || 'Failed to load routing status');
        }
      } catch {
        setError('Network error loading routing status');
        // Error loading routing status
      } finally {
        setLoading(false);
      }
    };

    loadRoutingStatus();
  }, [owner, repo, prNumber]);

  const handleToggle = async (enabled: boolean) => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`/api/pr/${owner}/${repo}/${prNumber}/route`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ enabled }),
      });

      const data: PRRoutingResponse = await response.json();

      if (data.ok) {
        setRouted(enabled);
        onToggle?.(enabled);
      } else {
        setError(data.error || 'Failed to update routing');
        // Routing toggle failed
      }
    } catch {
      setError('Network error updating routing');
      // Routing toggle error
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col space-y-2">
      <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg border">
        <div className="flex flex-col">
          <label htmlFor="codex-routing" className="text-sm font-medium text-gray-900">
            Codex Orchestrator Routing
          </label>
          <p className="text-xs text-gray-500 mt-1">
            {routed
              ? 'This PR will be processed by automated agents'
              : 'This PR follows standard human review process'
            }
          </p>
        </div>

        <button
          id="codex-routing"
          onClick={() => handleToggle(!routed)}
          disabled={loading}
          className={`
            relative inline-flex h-6 w-11 items-center rounded-full transition-colors
            focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2
            ${routed ? 'bg-blue-600' : 'bg-gray-200'}
            ${loading ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer hover:opacity-80'}
          `}
          aria-pressed={routed}
          aria-label={`${routed ? 'Disable' : 'Enable'} Codex routing`}
        >
          <span
            className={`
              inline-block h-4 w-4 transform rounded-full bg-white transition-transform
              ${routed ? 'translate-x-6' : 'translate-x-1'}
            `}
          />
        </button>
      </div>

      {/* Status indicators */}
      <div className="flex items-center space-x-3 text-xs">
        <div className={`flex items-center space-x-1 ${routed ? 'text-blue-600' : 'text-gray-500'}`}>
          <div className={`w-2 h-2 rounded-full ${routed ? 'bg-blue-600' : 'bg-gray-400'}`} />
          <span>{routed ? 'Routing to Codex' : 'Human triage'}</span>
        </div>

        {loading && (
          <div className="flex items-center space-x-1 text-gray-500">
            <div className="w-2 h-2 bg-gray-400 rounded-full animate-pulse" />
            <span>Updating...</span>
          </div>
        )}
      </div>

      {/* Error display */}
      {error && (
        <div className="p-2 bg-red-50 border border-red-200 rounded text-red-700 text-xs">
          <strong>Error:</strong> {error}
        </div>
      )}
    </div>
  );
}

/**
 * Orchestrator Status Component
 *
 * Displays overall orchestrator system status
 */
export interface OrchestratorStatusProps {
  refreshInterval?: number;
}

export interface OrchestratorSystemStatus {
  ok: boolean;
  agents: string[];
  routing_rules: number;
  environments: string[];
  version: string;
  error?: string;
}

export function OrchestratorStatus({ refreshInterval = 30000 }: OrchestratorStatusProps) {
  const [status, setStatus] = useState<OrchestratorSystemStatus | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadStatus = async () => {
      try {
        const response = await fetch('/api/orchestrator/status');
        const data: OrchestratorSystemStatus = await response.json();
        setStatus(data);
      } catch {
        // Error loading orchestrator status
        setStatus({
          ok: false,
          agents: [],
          routing_rules: 0,
          environments: [],
          version: 'unknown',
          error: 'Failed to load status'
        });
      } finally {
        setLoading(false);
      }
    };

    loadStatus();

    if (refreshInterval > 0) {
      const interval = setInterval(loadStatus, refreshInterval);
      return () => clearInterval(interval);
    }
  }, [refreshInterval]);

  if (loading) {
    return (
      <div className="p-4 bg-gray-50 rounded-lg border">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-300 rounded w-1/4 mb-2"></div>
          <div className="h-3 bg-gray-300 rounded w-1/2"></div>
        </div>
      </div>
    );
  }

  if (!status) {
    return (
      <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
        <p className="text-red-700 text-sm">Failed to load orchestrator status</p>
      </div>
    );
  }

  return (
    <div className="p-4 bg-gray-50 rounded-lg border">
      <div className="flex items-center space-x-2 mb-3">
        <div className={`w-3 h-3 rounded-full ${status.ok ? 'bg-green-500' : 'bg-red-500'}`} />
        <h3 className="text-sm font-medium">Orchestrator System</h3>
        <span className="text-xs text-gray-500">v{status.version}</span>
      </div>

      <div className="grid grid-cols-3 gap-4 text-xs">
        <div>
          <div className="font-medium text-gray-700">Agents</div>
          <div className="text-gray-600">{status.agents.length}</div>
        </div>
        <div>
          <div className="font-medium text-gray-700">Routing Rules</div>
          <div className="text-gray-600">{status.routing_rules}</div>
        </div>
        <div>
          <div className="font-medium text-gray-700">Environments</div>
          <div className="text-gray-600">{status.environments.length}</div>
        </div>
      </div>

      {status.error && (
        <div className="mt-2 p-2 bg-red-50 border border-red-200 rounded text-red-700 text-xs">
          <strong>Error:</strong> {status.error}
        </div>
      )}
    </div>
  );
}
