# Alpha Wave Rollout Guide

This checklist helps maintainers prepare each invite wave and track progress.

## Preparation
- Ensure features marked for the wave are stable.
- Verify environment variables in `.env.example` and the compose files.
- Confirm the invite list in `ALPHA_TESTERS.md` and draft the email.

## Invitation Flow
1. Send the invite email and share the private chat link.
2. Update `ALPHA_TESTERS.md` with the invitation date and status.
3. Remind testers to set `IS_ALPHA_USER=true` in `.env.dev`.

## Feedback Tracking
- Ask testers to log reproducible bugs in the issue tracker.
- Collect general impressions through [feedback-form.md](feedback-form.md).
- Summarize reports in [feedback-template.md](feedback-template.md).

## Monitoring
- Watch server logs and analytics for errors or spikes.
- Review feedback daily and prioritize fixes.
- Close the wave when blocking issues are resolved.
