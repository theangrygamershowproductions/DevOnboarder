import { useEffect, useState } from 'react';

interface FeedbackItem {
  id: number;
  type: string;
  status: string;
  description: string;
}

export default function FeedbackStatusBoard() {
  const feedbackUrl = import.meta.env.VITE_FEEDBACK_URL;
  const [items, setItems] = useState<FeedbackItem[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setError(null);
    fetch(`${feedbackUrl}/feedback`)
      .then(r => {
        if (!r.ok) throw new Error('Failed to load feedback');
        return r.json();
      })
      .then(d => setItems(d.feedback))
      .catch(() => setError('Failed to load feedback'));
  }, [feedbackUrl]);

  function updateStatus(id: number, status: string) {
    setError(null);
    fetch(`${feedbackUrl}/feedback/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status }),
    })
      .then(r => {
        if (!r.ok) throw new Error('Failed to update status');
      })
      .then(() => {
        setItems(items.map(i => (i.id === id ? { ...i, status } : i)));
      })
      .catch(() => setError('Failed to update status'));
  }

  return (
    <div>
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Type</th>
          <th>Status</th>
          <th>Description</th>
        </tr>
      </thead>
      <tbody>
        {items.map(item => (
          <tr key={item.id}>
            <td>{item.id}</td>
            <td>{item.type}</td>
            <td>
              <select
                aria-label={`status-${item.id}`}
                value={item.status}
                onChange={e => updateStatus(item.id, e.target.value)}
              >
                <option value="open">open</option>
                <option value="in progress">in progress</option>
                <option value="closed">closed</option>
              </select>
            </td>
            <td>{item.description}</td>
          </tr>
        ))}
      </tbody>
    </table>
    {error && <p role="alert">{error}</p>}
    </div>
  );
}
