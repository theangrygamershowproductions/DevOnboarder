/**
 * PR Routing API for Orchestrator Hub-and-Spoke System
 *
 * Provides endpoints for managing PR routing labels and orchestrator state.
 * Integrates with GitHub API to apply/remove codex:route labels.
 */

export interface PRRoutingRequest {
  owner: string;
  repo: string;
  number: number;
  enabled: boolean;
}

export interface PRRoutingResponse {
  ok: boolean;
  enabled: boolean;
  message?: string;
  error?: string;
}

export interface OrchestratorStatus {
  ok: boolean;
  agents: string[];
  routing_rules: number;
  environments: string[];
  version: string;
}

/**
 * GitHub API integration for PR routing
 */
export class PRRoutingService {
  private githubToken: string;
  private baseUrl: string;

  constructor(githubToken: string, baseUrl = 'https://api.github.com') {
    this.githubToken = githubToken;
    this.baseUrl = baseUrl;
  }

  /**
   * Enable or disable Codex routing for a specific PR
   */
  async updatePRRouting(request: PRRoutingRequest): Promise<PRRoutingResponse> {
    try {
      const { owner, repo, number, enabled } = request;
      const label = 'codex:route';

      const headers = {
        'Authorization': `token ${this.githubToken}`,
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      };

      if (enabled) {
        // Add the routing label
        const addLabelResponse = await fetch(
          `${this.baseUrl}/repos/${owner}/${repo}/issues/${number}/labels`,
          {
            method: 'POST',
            headers,
            body: JSON.stringify({ labels: [label] }),
          }
        );

        if (!addLabelResponse.ok) {
          throw new Error(`Failed to add label: ${addLabelResponse.statusText}`);
        }

        // Post notification comment
        const commentResponse = await fetch(
          `${this.baseUrl}/repos/${owner}/${repo}/issues/${number}/comments`,
          {
            method: 'POST',
            headers,
            body: JSON.stringify({
              body: '🔁 **Routing enabled**: Handing off to Codex orchestrator.\n\n' +
                    'This PR will now be processed by the automated agent routing system. ' +
                    'The orchestrator will analyze the changes and route to appropriate specialized agents.',
            }),
          }
        );

        if (!commentResponse.ok) {
          console.warn(`Failed to add comment: ${commentResponse.statusText}`);
        }

        console.log(`Enabled Codex routing for ${owner}/${repo}#${number}`);

      } else {
        // Remove the routing label
        const removeLabelResponse = await fetch(
          `${this.baseUrl}/repos/${owner}/${repo}/issues/${number}/labels/${label}`,
          {
            method: 'DELETE',
            headers,
          }
        );

        // Ignore 404 errors (label doesn't exist)
        if (!removeLabelResponse.ok && removeLabelResponse.status !== 404) {
          throw new Error(`Failed to remove label: ${removeLabelResponse.statusText}`);
        }

        // Post notification comment
        const commentResponse = await fetch(
          `${this.baseUrl}/repos/${owner}/${repo}/issues/${number}/comments`,
          {
            method: 'POST',
            headers,
            body: JSON.stringify({
              body: '⏹️ **Routing disabled**: Returning to human triage.\n\n' +
                    'This PR will now follow the standard human review process. ' +
                    'Automated agent routing has been disabled.',
            }),
          }
        );

        if (!commentResponse.ok) {
          console.warn(`Failed to add comment: ${commentResponse.statusText}`);
        }

        console.log(`Disabled Codex routing for ${owner}/${repo}#${number}`);
      }

      return {
        ok: true,
        enabled,
        message: enabled ? 'Routing enabled' : 'Routing disabled'
      };

    } catch (error) {
      console.error('PR routing error:', error);
      return {
        ok: false,
        enabled: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      };
    }
  }

  /**
   * Check current routing status for a PR
   */
  async getPRRoutingStatus(owner: string, repo: string, number: number): Promise<{
    ok: boolean;
    enabled: boolean;
    labels: string[];
    error?: string;
  }> {
    try {
      const headers = {
        'Authorization': `token ${this.githubToken}`,
        'Accept': 'application/vnd.github.v3+json',
      };

      const response = await fetch(
        `${this.baseUrl}/repos/${owner}/${repo}/pulls/${number}`,
        { headers }
      );

      if (!response.ok) {
        throw new Error(`Failed to get PR: ${response.statusText}`);
      }

      const pr = await response.json();
      const labels = pr.labels.map((label: any) =>
        typeof label === 'string' ? label : label.name || ''
      );

      const enabled = labels.includes('codex:route');

      return {
        ok: true,
        enabled,
        labels
      };

    } catch (error) {
      console.error('PR routing status error:', error);
      return {
        ok: false,
        enabled: false,
        labels: [],
        error: error instanceof Error ? error.message : 'Unknown error'
      };
    }
  }
}

/**
 * Get orchestrator system status
 */
export async function getOrchestratorStatus(): Promise<OrchestratorStatus> {
  try {
    // Note: In a real implementation, this would read from the actual config file
    // For now, return a mock status based on our known configuration
    return {
      ok: true,
      agents: ['codex_router', 'codex_triage', 'coverage_orchestrator', 'ci_triage_guard'],
      routing_rules: 4,
      environments: ['dev', 'staging', 'prod'],
      version: '1.0.0'
    };

  } catch (error) {
    console.error('Orchestrator status error:', error);
    return {
      ok: false,
      agents: [],
      routing_rules: 0,
      environments: [],
      version: 'unknown'
    };
  }
}
