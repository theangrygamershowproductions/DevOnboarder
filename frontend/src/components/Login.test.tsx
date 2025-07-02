import { render, screen, waitFor } from "@testing-library/react";
import { vi } from "vitest";
import Login from "./Login";

const AUTH_URL = "http://auth.example.com";

describe("Login", () => {
    beforeEach(() => {
        vi.stubEnv("VITE_AUTH_URL", AUTH_URL);
        localStorage.clear();
    });

    afterEach(() => {
        vi.unstubAllEnvs();
        vi.restoreAllMocks();
    });

    it("links to the auth service", () => {
        render(<Login />);
        const link = screen.getByRole("link", { name: /log in with discord/i });
        expect(link).toHaveAttribute("href", `${AUTH_URL}/login/discord`);
    });

    it("exchanges OAuth code and stores token", async () => {
        window.history.replaceState({}, "", "/login/discord/callback?code=abc");
        const fetchMock = vi
            .fn()
            .mockResolvedValue({ json: () => Promise.resolve({ token: "tok" }) });
        vi.stubGlobal("fetch", fetchMock);

        render(<Login />);

        await waitFor(() => expect(localStorage.getItem("jwt")).toBe("tok"));
        expect(fetchMock).toHaveBeenCalledWith(
            `${AUTH_URL}/login/discord/callback?code=abc`
        );
        expect(window.location.pathname).toBe("/");
    });

    it("fetches user info when token stored", async () => {
        localStorage.setItem("jwt", "tok");
        const fetchMock = vi
            .fn()
            .mockResolvedValueOnce({
                json: () =>
                    Promise.resolve({ id: "1", username: "dev", avatar: "img" }),
            })
            .mockResolvedValueOnce({
                json: () => Promise.resolve({ level: 3 }),
            })
            .mockResolvedValueOnce({
                json: () => Promise.resolve({ status: "intro" }),
            });
        vi.stubGlobal("fetch", fetchMock);

        render(<Login />);

        expect(await screen.findByTestId("user-welcome")).toHaveTextContent(
            "Logged in as dev"
        );
        expect(screen.getByRole("img", { name: "avatar" })).toHaveAttribute(
            "src",
            "https://cdn.discordapp.com/avatars/1/img.png"
        );
        expect(await screen.findByTestId("user-level")).toHaveTextContent(
            "Level: 3"
        );
        expect(await screen.findByTestId("onboarding-status")).toHaveTextContent(
            "Onboarding: intro"
        );
        expect(
            screen.getByRole("button", { name: /start onboarding/i })
        ).toBeInTheDocument();
    });
});
