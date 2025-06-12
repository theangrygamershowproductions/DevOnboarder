// PATCHED v1.0.0 auth-server/src/services/db.ts — simple db interface
export interface User {
  id: string;
  username: string;
  avatar?: string;
  isAdmin: boolean;
  isVerified: boolean;
  verificationType: string | null;
}

export const db = {
  async getUserById(id: string): Promise<User | null> {
    // TODO: replace with real database query
    if (id === '1') {
      return {
        id: '1',
        username: 'demo',
        avatar: 'avatar-url',
        isAdmin: true,
        isVerified: true,
        verificationType: 'GOV',
      };
    }
    return null;
  },
};
