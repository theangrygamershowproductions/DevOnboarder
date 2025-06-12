// PATCHED v0.1.1 VerificationList.tsx — Display verification requests

/* global fetch */

import React, { useEffect, useState } from 'react';

export default function VerificationList() {
  const [requests, setRequests] = useState<any[]>([]);

  useEffect(() => {
    fetch('/api/admin/verification', { headers: { 'X-Is-Admin': 'true' } })
      .then((res) => res.json())
      .then(setRequests)
      .catch(() => setRequests([]));
  }, []);

  return (
    <div>
      <h2 className="text-lg font-semibold">Verification Requests</h2>
      <ul>
        {requests.map((r) => (
          <li key={r.id}>
            {r.user_id} - {r.status}
          </li>
        ))}
      </ul>
    </div>
  );
}
