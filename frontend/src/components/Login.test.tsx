import { render, screen } from "@testing-library/react";
import { vi } from "vitest";
import Login from "./Login";

const AUTH_URL = "http://auth.example.com";

describe("Login", () => {
    beforeEach(() => {
        vi.stubEnv("VITE_AUTH_URL", AUTH_URL);
    });

    afterEach(() => {
        vi.unstubAllEnvs();
    });

    it("links to the auth service", () => {
        render(<Login />);
        const link = screen.getByRole("link", { name: /log in with discord/i });
        expect(link).toHaveAttribute("href", `${AUTH_URL}/login/discord`);
    });
});
