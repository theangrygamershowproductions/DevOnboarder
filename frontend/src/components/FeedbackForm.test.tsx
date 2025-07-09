import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { vi } from "vitest";
import FeedbackForm from "./FeedbackForm";

const URL = "http://feedback.example.com";

describe("FeedbackForm", () => {
  beforeEach(() => {
    vi.stubEnv("VITE_FEEDBACK_URL", URL);
  });
  afterEach(() => {
    vi.unstubAllEnvs();
    vi.restoreAllMocks();
  });

  it("posts feedback", async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValue({ json: () => Promise.resolve({ id: 1 }) });
    vi.stubGlobal("fetch", fetchMock);

    render(<FeedbackForm />);
    fireEvent.change(screen.getByRole("textbox"), {
      target: { value: "it broke" },
    });
    fireEvent.change(screen.getByRole("combobox"), {
      target: { value: "feature" },
    });
    fireEvent.click(screen.getByRole("button"));

    await waitFor(() =>
      expect(screen.getByText(/thanks for your feedback/i)).toBeInTheDocument()
    );
    expect(fetchMock).toHaveBeenCalledWith(`${URL}/feedback`, expect.any(Object));
  });
});
