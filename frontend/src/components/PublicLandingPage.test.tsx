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
        expect(screen.getByText(/Automated CI\/CD with 22\ GitHub Actions workflows/)).toBeInTheDocument();
    });

    it("shows test coverage feature", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText(/Comprehensive test coverage \(95%\ requirement\)/)).toBeInTheDocument();
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
        expect(screen.getByText(/Python 3.12 \ FastAPI \ SQLAlchemy/)).toBeInTheDocument();
    });

    it("displays project philosophy", () => {
        render(<PublicLandingPage />);
        expect(screen.getByText(/This project wasn't built to impress/)).toBeInTheDocument();
    });

    it("displays service health with online status", async () => {
        const fetchMock = vi.fn().mockImplementation(async () => {
            // Add a small delay to simulate realistic response time
            await new Promise(resolve => setTimeout(resolve, 50));
            return {
                ok: true,
                json: () => Promise.resolve({}),
            };
        });
        vi.stubGlobal("fetch", fetchMock);

        render(<PublicLandingPage />);

        // Wait for the service health check to complete - expect multiple services to be online
        const onlineElements = await screen.findAllByText("ONLINE", { exact: false });
        expect(onlineElements).toHaveLength(4); // 4 services should show online
    });

    it("displays service health with error status for failed response", async () => {
        const fetchMock = vi.fn().mockResolvedValue({
            ok: false,
            json: () => Promise.resolve({}),
        });
        vi.stubGlobal("fetch", fetchMock);

        render(<PublicLandingPage />);

        // Wait for the service health check to show error status - expect multiple services in error
        const errorElements = await screen.findAllByText("ERROR", { exact: false });
        expect(errorElements).toHaveLength(4); // 4 services should show error
    });

    it("displays service health with offline status for network error", async () => {
        const fetchMock = vi.fn().mockRejectedValue(new Error("Network error"));
        vi.stubGlobal("fetch", fetchMock);

        render(<PublicLandingPage />);

        // Wait for the service health check to show offline status - expect multiple services offline
        const offlineElements = await screen.findAllByText("OFFLINE", { exact: false });
        expect(offlineElements).toHaveLength(4); // 4 services should show offline
    });

    it("shows response time when service is responsive", async () => {
        const fetchMock = vi.fn().mockImplementation(async () => {
            // Add a small delay to simulate realistic response time
            await new Promise(resolve => setTimeout(resolve, 50));
            return {
                ok: true,
                json: () => Promise.resolve({}),
            };
        });
        vi.stubGlobal("fetch", fetchMock);

        render(<PublicLandingPage />);

        // Wait for response time to be displayed - expect multiple services to show response time
        const responseTimeElements = await screen.findAllByText(/Response: \dms/, { exact: false }, { timeout: 3000 });
        expect(responseTimeElements).toHaveLength(4); // 4 services should show response time
    });
});
