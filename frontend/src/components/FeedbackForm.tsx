import { useState } from 'react';

export default function FeedbackForm() {
  const feedbackUrl = import.meta.env.VITE_FEEDBACK_URL;
  const [type, setType] = useState('bug');
  const [description, setDescription] = useState('');
  const [submitted, setSubmitted] = useState<number | null>(null);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const resp = await fetch(`${feedbackUrl}/feedback`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type, description }),
    });
    const data = await resp.json();
    setSubmitted(data.id);
  }

  if (submitted) {
    return <p>Thanks for your feedback! #{submitted}</p>;
  }

  return (
    <form onSubmit={handleSubmit}>
      <label>
        Type
        <select value={type} onChange={e => setType(e.target.value)}>
          <option value="bug">Bug</option>
          <option value="feature">Feature</option>
        </select>
      </label>
      <label>
        Description
        <textarea
          value={description}
          onChange={e => setDescription(e.target.value)}
        />
      </label>
      <button type="submit">Submit Feedback</button>
    </form>
  );
}
