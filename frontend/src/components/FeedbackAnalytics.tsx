import { useEffect, useState } from 'react';

interface Analytics {
  total: number;
  breakdown: Record<string, Record<string, number>>;
}

export default function FeedbackAnalytics() {
  const feedbackUrl = import.meta.env.VITE_FEEDBACK_URL;
  const [data, setData] = useState<Analytics | null>(null);

  useEffect(() => {
    fetch(`${feedbackUrl}/feedback/analytics`)
      .then(r => r.json())
      .then(setData)
      .catch(console.error);
  }, [feedbackUrl]);

  if (!data) return <p>Loading...</p>;

  return (
    <div>
      <p>Total feedback: {data.total}</p>
      {Object.entries(data.breakdown).map(([type, statuses]) => (
        <div key={type}>
          <h3>{type}</h3>
          <ul>
            {Object.entries(statuses).map(([status, count]) => (
              <li key={status}>
                {status}: {count}
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}
