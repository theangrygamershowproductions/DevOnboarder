import React, { useState, useEffect } from 'react';

interface ScriptInfo {
  name: string;
  path: string;
  description: string;
  category: string;
  executable: boolean;
  last_modified: string;
  size_bytes: number;
}

interface ExecutionResult {
  execution_id: string;
  script_path: string;
  status: 'running' | 'completed' | 'failed';
  exit_code?: number;
  output: string;
  error: string;
  start_time: string;
  end_time?: string;
  duration_seconds?: number;
}

interface ExecutionRequest {
  script_path: string;
  args?: string[];
  background: boolean;
}

const Dashboard: React.FC = () => {
  const [scripts, setScripts] = useState<ScriptInfo[]>([]);
  const [executions, setExecutions] = useState<ExecutionResult[]>([]);
  const [selectedScript, setSelectedScript] = useState<ScriptInfo | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [isExecuting, setIsExecuting] = useState<boolean>(false);
  const [executionArgs, setExecutionArgs] = useState<string>('');
  const [backgroundExecution, setBackgroundExecution] = useState<boolean>(false);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');
  const [wsConnected, setWsConnected] = useState<boolean>(false);

  const dashboardUrl = process.env.REACT_APP_DASHBOARD_URL || 'http://localhost:8003';
  const dashboardWsUrl = process.env.REACT_APP_DASHBOARD_WS_URL || 'ws://localhost:8003/ws';

  // WebSocket connection for real-time updates
  useEffect(() => {
    const ws = new WebSocket(dashboardWsUrl);

    ws.onopen = () => {
      setWsConnected(true);
    };

    ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      if (message.type === 'execution_update') {
        const updatedExecution = message.data as ExecutionResult;
        setExecutions(prev =>
          prev.map(exec =>
            exec.execution_id === updatedExecution.execution_id
              ? updatedExecution
              : exec
          )
        );
      }
    };

    ws.onclose = () => {
      setWsConnected(false);
    };

    ws.onerror = () => {
      setWsConnected(false);
    };

    return () => {
      ws.close();
    };
  }, []);

  // Load scripts on component mount
  useEffect(() => {
    loadScripts();
    loadExecutions();
  }, []);

  const loadScripts = async () => {
    try {
      const response = await fetch(`${dashboardUrl}/api/scripts`);
      if (!response.ok) throw new Error('Failed to load scripts');
      const data = await response.json();
      setScripts(data);
    } catch (err) {
      setError(`Failed to load scripts: ${err}`);
    } finally {
      setLoading(false);
    }
  };

  const loadExecutions = async () => {
    try {
      const response = await fetch(`${dashboardUrl}/api/executions`);
      if (!response.ok) throw new Error('Failed to load executions');
      const data = await response.json();
      setExecutions(data);
    } catch {
      // Failed to load executions - will be handled by empty state
    }
  };

  const executeScript = async () => {
    if (!selectedScript) return;

    setIsExecuting(true);
    setError('');

    try {
      const request: ExecutionRequest = {
        script_path: selectedScript.path,
        args: executionArgs.trim() ? executionArgs.split(' ') : [],
        background: backgroundExecution,
      };

      const response = await fetch(`${dashboardUrl}/api/execute`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(request),
      });

      if (!response.ok) throw new Error('Failed to execute script');

      const result = await response.json();
      setExecutions(prev => [result, ...prev]);

      // Clear form
      setExecutionArgs('');
      setSelectedScript(null);

    } catch (err) {
      setError(`Execution failed: ${err}`);
    } finally {
      setIsExecuting(false);
    }
  };

  // Filter scripts based on category and search term
  const filteredScripts = scripts.filter(script => {
    const matchesCategory = selectedCategory === 'all' || script.category === selectedCategory;
    const matchesSearch = script.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         script.description.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  // Get unique categories
  const categories = ['all', ...Array.from(new Set(scripts.map(s => s.category))).sort()];

  const formatDuration = (seconds?: number) => {
    if (!seconds) return 'N/A';
    if (seconds < 60) return `${seconds.toFixed(1)}s`;
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}m ${remainingSeconds.toFixed(1)}s`;
  };

  const getStatusBadgeClass = (status: string) => {
    switch (status) {
      case 'running': return 'bg-blue-100 text-blue-800';
      case 'completed': return 'bg-green-100 text-green-800';
      case 'failed': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="text-lg">Loading dashboard...</div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">CI Troubleshooting Dashboard</h1>
        <p className="text-gray-600">
          Discover and execute automation scripts for DevOnboarder
        </p>
        <div className="mt-4 flex items-center space-x-4">
          <span className={`px-2 py-1 rounded text-sm ${wsConnected ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
            WebSocket: {wsConnected ? 'Connected' : 'Disconnected'}
          </span>
          <span className="text-sm text-gray-500">
            Found {scripts.length} scripts
          </span>
        </div>
      </div>

      {error && (
        <div className="mb-6 p-4 bg-red-100 border border-red-400 text-red-700 rounded">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Script Discovery Panel */}
        <div className="space-y-6">
          <div className="bg-white rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Script Discovery</h2>

            {/* Filters */}
            <div className="space-y-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-2">Category</label>
                <select
                  value={selectedCategory}
                  onChange={(e) => setSelectedCategory(e.target.value)}
                  className="w-full border border-gray-300 rounded px-3 py-2"
                >
                  {categories.map(cat => (
                    <option key={cat} value={cat}>
                      {cat === 'all' ? 'All Categories' : cat.charAt(0).toUpperCase() + cat.slice(1)}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium mb-2">Search</label>
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search scripts..."
                  className="w-full border border-gray-300 rounded px-3 py-2"
                />
              </div>
            </div>

            {/* Script List */}
            <div className="space-y-2 max-h-96 overflow-y-auto">
              {filteredScripts.map(script => (
                <div
                  key={script.path}
                  className={`p-3 border rounded cursor-pointer transition-colors ${
                    selectedScript?.path === script.path
                      ? 'border-blue-500 bg-blue-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                  onClick={() => setSelectedScript(script)}
                >
                  <div className="flex justify-between items-start mb-1">
                    <h3 className="font-medium text-sm">{script.name}</h3>
                    <span className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded">
                      {script.category}
                    </span>
                  </div>
                  <p className="text-xs text-gray-600 mb-2">
                    {script.description.length > 80
                      ? `${script.description.substring(0, 80)}...`
                      : script.description}
                  </p>
                  <div className="flex justify-between text-xs text-gray-500">
                    <span>{script.path}</span>
                    <span>{(script.size_bytes / 1024).toFixed(1)} KB</span>
                  </div>
                </div>
              ))}
            </div>

            {filteredScripts.length === 0 && (
              <div className="text-center py-8 text-gray-500">
                No scripts found matching your criteria.
              </div>
            )}
          </div>

          {/* Execution Panel */}
          {selectedScript && (
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Execute Script</h2>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Selected Script</label>
                  <p className="text-sm bg-gray-100 p-2 rounded">{selectedScript.name}</p>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Arguments</label>
                  <input
                    type="text"
                    value={executionArgs}
                    onChange={(e) => setExecutionArgs(e.target.value)}
                    placeholder="Enter script arguments..."
                    className="w-full border border-gray-300 rounded px-3 py-2"
                  />
                </div>

                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="background"
                    checked={backgroundExecution}
                    onChange={(e) => setBackgroundExecution(e.target.checked)}
                    className="mr-2"
                  />
                  <label htmlFor="background" className="text-sm">
                    Run in background
                  </label>
                </div>

                <button
                  onClick={executeScript}
                  disabled={isExecuting}
                  className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700 disabled:bg-gray-400"
                >
                  {isExecuting ? 'Executing...' : 'Execute Script'}
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Execution Results Panel */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">Recent Executions</h2>

          <div className="space-y-4 max-h-96 overflow-y-auto">
            {executions.map(execution => (
              <div key={execution.execution_id} className="border border-gray-200 rounded p-4">
                <div className="flex justify-between items-start mb-2">
                  <h3 className="font-medium text-sm">{execution.script_path}</h3>
                  <span className={`px-2 py-1 rounded text-xs font-medium ${getStatusBadgeClass(execution.status)}`}>
                    {execution.status}
                  </span>
                </div>

                <div className="text-xs text-gray-600 mb-2">
                  <div>Started: {new Date(execution.start_time).toLocaleString()}</div>
                  {execution.end_time && (
                    <div>Ended: {new Date(execution.end_time).toLocaleString()}</div>
                  )}
                  <div>Duration: {formatDuration(execution.duration_seconds)}</div>
                  {execution.exit_code !== null && (
                    <div>Exit Code: {execution.exit_code}</div>
                  )}
                </div>

                {execution.output && (
                  <div className="mt-2">
                    <h4 className="text-xs font-medium mb-1">Output:</h4>
                    <pre className="text-xs bg-gray-100 p-2 rounded overflow-x-auto">
                      {execution.output.length > 200
                        ? `${execution.output.substring(0, 200)}...`
                        : execution.output}
                    </pre>
                  </div>
                )}

                {execution.error && (
                  <div className="mt-2">
                    <h4 className="text-xs font-medium mb-1 text-red-600">Error:</h4>
                    <pre className="text-xs bg-red-50 p-2 rounded overflow-x-auto text-red-700">
                      {execution.error.length > 200
                        ? `${execution.error.substring(0, 200)}...`
                        : execution.error}
                    </pre>
                  </div>
                )}
              </div>
            ))}
          </div>

          {executions.length === 0 && (
            <div className="text-center py-8 text-gray-500">
              No executions yet. Select a script and run it to see results here.
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
