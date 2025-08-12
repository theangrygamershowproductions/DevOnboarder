import { describe, it, expect, vi } from "vitest";
import { render } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import ProtectedRoute from "../../routes/ProtectedRoute";

// Mock react-router-dom Navigate
const mockNavigate = vi.fn();
vi.mock("react-router-dom", async () => {
    const actual = await vi.importActual("react-router-dom");
    return {
        ...actual,
        Navigate: ({ to }: { to: string }) => {
            mockNavigate(to);
            return <div data-testid="navigate-mock">{to}</div>;
        }
    };
});

// Mock window.location
Object.defineProperty(window, "location", {
    value: {
        pathname: "/dashboard"
    },
    writable: true
});

describe("Login Redirect Logic", () => {
    beforeEach(() => {
        mockNavigate.mockClear();
        window.location.pathname = "/dashboard";
    });

    it("redirects unauthenticated users to root", () => {
        render(
            <BrowserRouter>
                <ProtectedRoute isAuthenticated={false} hasDashboard={false}>
                    <div>Protected Content</div>
                </ProtectedRoute>
            </BrowserRouter>
        );

        expect(mockNavigate).toHaveBeenCalledWith("/");
    });

    it("keeps authenticated users with dashboard access on dashboard", () => {
        window.location.pathname = "/dashboard";

        const { getByText } = render(
            <BrowserRouter>
                <ProtectedRoute isAuthenticated={true} hasDashboard={true}>
                    <div>Dashboard Content</div>
                </ProtectedRoute>
            </BrowserRouter>
        );

        expect(getByText("Dashboard Content")).toBeInTheDocument();
        expect(mockNavigate).not.toHaveBeenCalled();
    });

    it("redirects authenticated users without dashboard to profile", () => {
        window.location.pathname = "/dashboard";

        render(
            <BrowserRouter>
                <ProtectedRoute isAuthenticated={true} hasDashboard={false}>
                    <div>Dashboard Content</div>
                </ProtectedRoute>
            </BrowserRouter>
        );

        expect(mockNavigate).toHaveBeenCalledWith("/profile");
    });
});
