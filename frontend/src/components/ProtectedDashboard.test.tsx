import { render, screen, waitFor } from "@testing-library/react";
import { vi } from "vitest";
import ProtectedDashboard from "./ProtectedDashboard";

// Mock the child components
vi.mock("./Login", () => ({
    default: () => <div data-testid="login-component">Login Component</div>
}));

vi.mock("./FeedbackForm", () => ({
    default: () => <div data-testid="feedback-form">Feedback Form</div>
}));

vi.mock("./FeedbackStatusBoard", () => ({
    default: () => <div data-testid="feedback-status-board">Feedback Status Board</div>
}));

vi.mock("./FeedbackAnalytics", () => ({
    default: () => <div data-testid="feedback-analytics">Feedback Analytics</div>
}));

// Mock environment variables
Object.defineProperty(import.meta, "env", {
    value: {
        VITE_AUTH_URL: "http://localhost:8002"
    }
}) as any;

describe("ProtectedDashboard Component", () => {
    beforeEach(() => {
        localStorage.clear();
        vi.clearAllMocks();
    }) as any;

    it("renders loading spinner initially", () => {
        // Remove any token to ensure not authenticated
        localStorage.removeItem("jwt");

        render(<ProtectedDashboard />);

        // Should show login component when not authenticated
        expect(screen.getByText("Staff Dashboard")).toBeInTheDocument();
        expect(screen.getByText("Please authenticate with Discord to continue")).toBeInTheDocument();
    }) as any;

    it("renders login component when not authenticated", async () => {
        global.fetch = vi.fn().mockRejectedValue(new Error("Unauthorized")) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getByText("Staff Dashboard")).toBeInTheDocument();
            expect(screen.getByText("Please authenticate with Discord to continue")).toBeInTheDocument();
            expect(screen.getByTestId("login-component")).toBeInTheDocument();
        }) as any;
    }) as any;

    it("renders dashboard for authenticated user", async () => {
        localStorage.setItem("jwt", "valid-token");

        global.fetch = vi.fn().mockResolvedValue({
            ok: true,
            json: () => Promise.resolve({
                username: "testuser",
                roles: ["MEMBER"]
            })
        }) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getByText("Welcome back, testuser!")).toBeInTheDocument();
            expect(screen.getByText(/Role: MEMBER/)).toBeInTheDocument();
        }) as any;
    }) as any;

    it("shows feedback management section", async () => {
        localStorage.setItem("jwt", "valid-token");

        global.fetch = vi.fn().mockResolvedValue({
            ok: true,
            json: () => Promise.resolve({
                username: "testuser",
                roles: ["MODERATOR"]
            })
        }) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getByText("Feedback Management")).toBeInTheDocument();
            expect(screen.getByTestId("feedback-form")).toBeInTheDocument();
            expect(screen.getByTestId("feedback-status-board")).toBeInTheDocument();
        }) as any;
    }) as any;

    it("shows analytics for admin users", async () => {
        localStorage.setItem("jwt", "valid-token");

        global.fetch = vi.fn().mockResolvedValue({
            ok: true,
            json: () => Promise.resolve({
                username: "adminuser",
                roles: ["ADMINISTRATOR"]
            })
        }) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getByText("Analytics")).toBeInTheDocument();
            expect(screen.getByTestId("feedback-analytics")).toBeInTheDocument();
        }) as any;
    }) as any;

    it("shows CI dashboard for owner users", async () => {
        localStorage.setItem("jwt", "valid-token");

        global.fetch = vi.fn().mockResolvedValue({
            ok: true,
            json: () => Promise.resolve({
                username: "owneruser",
                roles: ["OWNER"]
            })
        }) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getAllByText("CI Dashboard")).toHaveLength(2);
            expect(screen.getByText("Open CI Dashboard (External)")).toBeInTheDocument();
        }) as any;
    }) as any;

    it("shows administrator warning for admin users", async () => {
        localStorage.setItem("jwt", "valid-token");

        global.fetch = vi.fn().mockResolvedValue({
            ok: true,
            json: () => Promise.resolve({
                username: "adminuser",
                roles: ["ADMINISTRATOR"]
            })
        }) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getByText("Administrator Access")).toBeInTheDocument();
            expect(screen.getByText("You have administrative privileges. Use them responsibly.")).toBeInTheDocument();
        }) as any;
    }) as any;

    it("shows quick actions section", async () => {
        localStorage.setItem("jwt", "valid-token");

        global.fetch = vi.fn().mockResolvedValue({
            ok: true,
            json: () => Promise.resolve({
                username: "testuser",
                roles: ["MEMBER"]
            })
        }) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getByText("Quick Actions")).toBeInTheDocument();
            expect(screen.getByText("API Documentation")).toBeInTheDocument();
            expect(screen.getByText("Auth Service")).toBeInTheDocument();
            expect(screen.getByText("Public Site")).toBeInTheDocument();
        }) as any;
    }) as any;

    it("handles authentication errors gracefully", async () => {
        localStorage.setItem("jwt", "invalid-token");

        global.fetch = vi.fn().mockResolvedValue({
            ok: false,
            status: 401
        }) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getByText("Staff Dashboard")).toBeInTheDocument();
            expect(screen.getByTestId("login-component")).toBeInTheDocument();
        }) as any;

        // Token should be removed from localStorage
        expect(localStorage.getItem("jwt")).toBeNull();
    }) as any;

    it("handles network errors during authentication", async () => {
        localStorage.setItem("jwt", "valid-token");

        global.fetch = vi.fn().mockRejectedValue(new Error("Network error")) as any;

        render(<ProtectedDashboard />);

        await waitFor(() => {
            expect(screen.getByTestId("login-component")).toBeInTheDocument();
        }) as any;

        // Token should be removed from localStorage on network error
        expect(localStorage.getItem("jwt")).toBeNull();
    }) as any;
}) as any;
