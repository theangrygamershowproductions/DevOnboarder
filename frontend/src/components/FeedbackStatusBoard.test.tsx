import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { vi } from "vitest";
import FeedbackStatusBoard from "./FeedbackStatusBoard";

const URL = "http://feedback.example.com";

describe("FeedbackStatusBoard", () => {
  beforeEach(() => {
    vi.stubEnv("VITE_FEEDBACK_URL", URL);
  });
  afterEach(() => {
    vi.unstubAllEnvs();
    vi.restoreAllMocks();
  });

  it("lists items and updates status", async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce({
        ok: true,
        json: () =>
          Promise.resolve({
            feedback: [
              { id: 1, type: "bug", status: "open", description: "bad" },
            ],
          }),
      })
      .mockResolvedValueOnce({ ok: true, json: () => Promise.resolve({}) });
    vi.stubGlobal("fetch", fetchMock);

    render(<FeedbackStatusBoard />);
    await screen.findByText("bad");
    fireEvent.change(screen.getByLabelText("status-1"), {
      target: { value: "closed" },
    });
    await waitFor(() =>
      expect(fetchMock).toHaveBeenLastCalledWith(
        `${URL}/feedback/1`,
        expect.objectContaining({ method: "PATCH" })
      )
    );
  });

  it("shows an error when update fails", async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce({
        ok: true,
        json: () =>
          Promise.resolve({
            feedback: [
              { id: 1, type: "bug", status: "open", description: "bad" },
            ],
          }),
      })
      .mockResolvedValueOnce({ ok: false });
    vi.stubGlobal("fetch", fetchMock);

    render(<FeedbackStatusBoard />);
    await screen.findByText("bad");
    fireEvent.change(screen.getByLabelText("status-1"), {
      target: { value: "closed" },
    });
    await waitFor(() =>
      expect(screen.getByRole("alert")).toHaveTextContent(/failed/i)
    );
  });
});
