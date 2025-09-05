import { render, screen } from "@testing-library/react";
import { vi } from "vitest";
import PublicLandingPage from "./PublicLandingPage";

// Mock environment variables
vi.stubEnv("VITE_AUTH_URL", "http://auth.example.com");

describe("PublicLandingPage Component", () => {
    beforeEach(() => {
        vi.clearAllMocks();
        localStorage.clear();
    });

    afterEach(() => {
        vi.restoreAllMocks();
        vi.unstubAllGlobals();
    });

    it("renders the main heading", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText("Comprehensive Onboarding Platform")).toBeInTheDocument();
    });

    it("renders the description", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText(/Designed to work quietly and reliably/)).toBeInTheDocument();
    });

    it("shows the dashboard button", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText("Staff Dashboard")).toBeInTheDocument();
    });

    it("displays project overview section", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText("Project Overview")).toBeInTheDocument();
    });

    it("shows Discord integration feature", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText(/Multi-environment Discord bot integration/)).toBeInTheDocument();
    });

    it("shows automation feature", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText(/Automated CI\/CD with 22\+ GitHub Actions workflows/)).toBeInTheDocument();
    });

    it("shows test coverage feature", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText(/Comprehensive test coverage \(95%\+ requirement\)/)).toBeInTheDocument();
    });

    it("handles view source button", () => {
        render(<PublicLandingPage />);
        const viewSourceButton = screen.getByText("View Source");
        expect(viewSourceButton).toBeInTheDocument();
        expect(viewSourceButton.closest('a')).toHaveAttribute('href', 'https://github.com/theangrygamershowproductions/DevOnboarder');
    });

    // Service status tests
    it("displays service status section", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText("Service Status")).toBeInTheDocument();
    });

    it("shows all service names", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText("Authentication Service")).toBeInTheDocument();
        expect(screen.getByText("API Backend")).toBeInTheDocument();
        expect(screen.getByText("Discord Integration")).toBeInTheDocument();
        expect(screen.getByText("Dashboard Service")).toBeInTheDocument();
    });

    it("displays public APIs section", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText("Public APIs")).toBeInTheDocument();
        expect(screen.getByText("Health Endpoints")).toBeInTheDocument();
        expect(screen.getByText("Documentation")).toBeInTheDocument();
    });

    it("shows backend technology stack", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText(/Python 3.12 \+ FastAPI \+ SQLAlchemy/)).toBeInTheDocument();
    });

    it("displays project philosophy", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText(/This project wasn't built to impress/)).toBeInTheDocument();
    });

    it("displays service health with online status", async () => {
        const fetchMock = vi.fn().mockResolvedValue({
            ok: true,
            json: () => Promise.resolve({}),
        });
        vi.stubGlobal("fetch", fetchMock);

        render(<PublicLandingPage />);

        // Wait for the service health check to complete
        await screen.findByText("ONLINE", { exact: false });
    });

    it("displays service health with error status for failed response", async () => {
        const fetchMock = vi.fn().mockResolvedValue({
            ok: false,
            json: () => Promise.resolve({}),
        });
        vi.stubGlobal("fetch", fetchMock);

        render(<PublicLandingPage />);

        // Wait for the service health check to show error status
        await screen.findByText("ERROR", { exact: false });
    });

    it("displays service health with offline status for network error", async () => {
        const fetchMock = vi.fn().mockRejectedValue(new Error("Network error"));
        vi.stubGlobal("fetch", fetchMock);

        render(<PublicLandingPage />);

        // Wait for the service health check to show offline status
        await screen.findByText("OFFLINE", { exact: false });
    });

    it("shows response time when service is responsive", async () => {
        const fetchMock = vi.fn().mockResolvedValue({
            ok: true,
            json: () => Promise.resolve({}),
        });
        vi.stubGlobal("fetch", fetchMock);

        render(<PublicLandingPage />);

        // Wait for response time to be displayed
        await screen.findByText(/Response: \d+ms/, { exact: false });
    });
});
