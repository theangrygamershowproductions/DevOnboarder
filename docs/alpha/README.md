# Invite-Only Alpha Onboarding

This template outlines how to onboard early testers who receive special access.

## Objectives
- Exercise the system in real conditions.
- Gather bug reports and user experience feedback.
- Prepare for a broader release after issues are addressed.

## Steps for Participants
1. Accept your invitation and join the private communication channel.
2. Follow [docs/README.md](../README.md) to set up the project locally.
3. Use the app and note any problems or confusing areas.
4. Submit feedback through the issue tracker for bugs. For general impressions
   or anonymous comments, fill out
   [feedback-form.md](feedback-form.md).
5. Expect occasional downtime or breaking changes while we iterate.
6. Update [../../ALPHA_TESTERS.md](../../ALPHA_TESTERS.md) with your feedback status.
7. Track progress in [feedback-template.md](feedback-template.md) as issues are addressed.

Use the form for quick thoughts or private comments. Open an issue when you
encounter a reproducible bug or have a feature suggestion so we can track it.

## Alpha Feature Flag
Set `IS_ALPHA_USER=true` in your `.env.dev` file to enable access to routes meant only for testers. See `.env.example` for the default value.

## Thank You
Invite-only testers help shape the stability of the project. Your feedback directly influences upcoming releases.

Maintainers should follow [alpha-wave-rollout-guide.md](alpha-wave-rollout-guide.md) when scheduling each invite wave.

For a sample invitation, see [emails/invite_alpha_email.md](../../emails/invite_alpha_email.md).
Refer to [emails/style-guide.md](../../emails/style-guide.md) for our email tone guidelines.

## Marketing Site Preview
Get a first look at the upcoming website in
[frontend/index.html](../../frontend/index.html).
Share this link with prospective testers who want a quick overview.

## Setup Validation
The steps in [docs/README.md](../README.md) were verified on Windows 11
(using WSL&nbsp;2), macOS Ventura, and Ubuntu&nbsp;22.04. If you run into
platform-specific issues, open an issue so we can update the guide.

