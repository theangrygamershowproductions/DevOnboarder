// PATCHED v0.1.1 UserList.tsx — Display user list

/* global fetch */

import React, { useEffect, useState } from 'react';

export default function UserList() {
  const [users, setUsers] = useState<any[]>([]);

  useEffect(() => {
    fetch('/api/admin/users', { headers: { 'X-Is-Admin': 'true' } })
      .then((res) => res.json())
      .then(setUsers)
      .catch(() => setUsers([]));
  }, []);

  return (
    <div>
      <h2 className="text-lg font-semibold">User Roles</h2>
      <ul>
        {users.map((u) => (
          <li key={u.id}>{JSON.stringify(u)}</li>
        ))}
      </ul>
    </div>
  );
}
