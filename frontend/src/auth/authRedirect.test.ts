import { describe, it, expect } from "vitest";
import { authRedirectTarget, Session } from "./authRedirect";

describe("authRedirect", () => {
    it("redirects unauthenticated users to root", () => {
        const session: Session = { isAuthenticated: false, hasDashboard: false };
        expect(authRedirectTarget(session)).toBe("/");
    });

    it("redirects authenticated users with dashboard access to dashboard", () => {
        const session: Session = { isAuthenticated: true, hasDashboard: true };
        expect(authRedirectTarget(session)).toBe("/dashboard");
    });

    it("redirects authenticated users without dashboard access to profile", () => {
        const session: Session = { isAuthenticated: true, hasDashboard: false };
        expect(authRedirectTarget(session)).toBe("/profile");
    });
});
