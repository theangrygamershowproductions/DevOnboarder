import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { vi } from "vitest";
import Header from "./Header";

// Mock the env variable
vi.stubEnv("VITE_AUTH_URL", "http://auth.example.com");

describe("Header Component", () => {
    beforeEach(() => {
        localStorage.clear();
        vi.clearAllMocks();
    });

    it("renders the header title", () => {
        render(<Header />);
        expect(screen.getByText("DevOnboarder")).toBeInTheDocument();
    });

    it("shows login link when not authenticated", () => {
        render(<Header />);
        expect(screen.getByText("Staff Login")).toBeInTheDocument();
    });

    it("shows user info when authenticated", async () => {
        // Set JWT token to trigger auth check
        localStorage.setItem("jwt", "valid-token");

        // Mock successful auth
        global.fetch = vi.fn().mockResolvedValueOnce({
            ok: true,
            json: vi.fn().mockResolvedValueOnce({
                username: "testuser",
                discord_id: "123",
                avatar: "avatar.png",
                roles: ["ADMIN"],
            }),
        });

        render(<Header />);

        // Wait for loading to complete and user data to load
        await waitFor(() => {
            expect(screen.getByText("testuser")).toBeInTheDocument();
            expect(screen.getByText("ADMIN")).toBeInTheDocument();
            expect(screen.getByText("Dashboard")).toBeInTheDocument();
        });
    });

    it("handles logout correctly", async () => {
        // Set JWT token to trigger auth check
        localStorage.setItem("jwt", "valid-token");

        // Mock successful auth
        global.fetch = vi.fn().mockResolvedValueOnce({
            ok: true,
            json: vi.fn().mockResolvedValueOnce({
                username: "testuser",
                discord_id: "123",
                avatar: "avatar.png",
                roles: ["ADMIN"],
            }),
        });

        delete (window as any).location;
        (window as any).location = { href: "" };

        render(<Header />);

        await waitFor(() => {
            expect(screen.getByText("testuser")).toBeInTheDocument();
        });

        const logoutButton = screen.getByTitle("Logout");
        fireEvent.click(logoutButton);

        expect(window.location.href).toBe("/");
        expect(localStorage.getItem("jwt")).toBeNull();
    });    it("displays user avatar when available", async () => {
        // Set JWT token to trigger auth check
        localStorage.setItem("jwt", "valid-token");

        // Mock successful auth with avatar
        global.fetch = vi.fn().mockResolvedValueOnce({
            ok: true,
            json: vi.fn().mockResolvedValueOnce({
                username: "testuser",
                discord_id: "123",
                avatar: "avatar",
                roles: ["ADMIN"],
            }),
        });

        render(<Header />);

        await waitFor(() => {
            const avatar = screen.getByRole("img");
            expect(avatar).toHaveAttribute("src", "https://cdn.discordapp.com/avatars/123/avatar.png?size=64");
            expect(avatar).toHaveAttribute("alt", "testuser's avatar");
        });
    });

    it("handles missing user avatar gracefully", async () => {
        // Set JWT token to trigger auth check
        localStorage.setItem("jwt", "valid-token");

        // Mock successful auth without avatar
        global.fetch = vi.fn().mockResolvedValueOnce({
            ok: true,
            json: vi.fn().mockResolvedValueOnce({
                username: "testuser",
                discord_id: "123",
                roles: ["ADMIN"],
            }),
        });

        render(<Header />);

        await waitFor(() => {
            expect(screen.getByText("testuser")).toBeInTheDocument();
            const avatar = screen.getByRole("img");
            expect(avatar).toHaveAttribute("src", "https://cdn.discordapp.com/embed/avatars/3.png");
        });
    });

    it("handles invalid user data in localStorage", async () => {
        localStorage.setItem("jwt", "invalid-token");

        // Mock failed auth
        global.fetch = vi.fn().mockResolvedValueOnce({
            ok: false,
        });

        render(<Header />);

        // Wait for auth check to complete and show login
        await waitFor(() => {
            expect(screen.getByText("Staff Login")).toBeInTheDocument();
        });
    });

    it("handles network error during auth check", async () => {
        localStorage.setItem("jwt", "valid-token");

        // Mock network error
        global.fetch = vi.fn().mockRejectedValue(new Error("Network error"));

        render(<Header />);

        // Wait for auth check to fail and show login
        await waitFor(() => {
            expect(screen.getByText("Staff Login")).toBeInTheDocument();
        });

        // Token should be cleared on auth failure
        expect(localStorage.getItem("jwt")).toBeNull();
    });

    it("renders navigation links correctly", () => {
        render(<Header />);
        expect(screen.getByText("DevOnboarder")).toBeInTheDocument();
    });
});
