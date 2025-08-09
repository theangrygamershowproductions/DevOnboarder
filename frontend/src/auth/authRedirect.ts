export type Session = { isAuthenticated: boolean; hasDashboard: boolean; };

export function authRedirectTarget(s: Session): string {
  if (!s.isAuthenticated) return "/";
  return s.hasDashboard ? "/dashboard" : "/profile";
}
