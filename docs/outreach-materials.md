# Outreach Materials

This page collects snippets for promoting DevOnboarder and tracking feedback.

## 1️⃣ GitHub ReadMe CTA (Copy-Paste Ready)

> **Found DevOnboarder useful?**
> If this helped you speed up onboarding, save time, or avoid headaches — please
> [⭐️ star the repo](https://github.com/theangrygamershowproductions/DevOnboarder),
> or [open an issue](https://github.com/theangrygamershowproductions/DevOnboarder/issues/new/choose)
> with your feedback or suggestions.
> Your input directly shapes future improvements. Thanks for helping make onboarding suck less!

## 2️⃣ Demo Video Script (60–90 seconds, “Show Don’t Tell” Style)

**[Opening Shot: VSCode open, terminal ready]**

- **Voice/Text overlay:**
  _"Hey, this is DevOnboarder — a no-BS way to get new devs up and running, fast."_

**[Show: `ask` Command]**

- "Need answers fast? Just type:"

    ```shell
    devonboarder ask 'How do I set up the local dev server?'
    ```

- _Shows answer, points out the snippet drops into the right doc or channel._

**[Show: `drop` Command]**

- "Found something useful? Drop it straight into the onboarding doc or team channel."

    ```shell
    devonboarder drop 'Debugging steps for the staging server'
    ```

**[Show: Journaling / Log Flow]**

- "Everything’s logged automatically, so nobody’s repeating the same Q&A dance every week."

**[Closing Shot: README with star, issue, and feedback CTA visible]**

- "I built this to scratch my own itch. If it helps you, drop a star or open an
  issue — let’s make onboarding better for all of us."

## 3️⃣ Outreach Message Drafts (Reddit, Discord, etc.)

### Short Community Post

> 🚀 **Built a better onboarding flow for devs — sharing for feedback**
>
> Just open-sourced [DevOnboarder](https://github.com/theangrygamershowproductions/DevOnboarder)
> after getting tired of repeating myself onboarding folks (and myself) for new projects.
>
> It hooks into VSCode, Discord, and GitHub.
>
> - Instant answers (`ask`)
> - Fast docs drop-ins (`drop`)
> - Automatic journaling for repeat questions
>
> If onboarding sucks where you are, maybe this fixes it. Feedback or test drives welcome!

### Short Discord DM or Channel Drop

> Just open-sourced a tool I built to make onboarding less painful.
> [DevOnboarder](https://github.com/theangrygamershowproductions/DevOnboarder) —
> for indie devs, open source, or anyone onboarding new folks.
> Always happy for feedback or stars if it helps!

## 4️⃣ Impact/Feedback Log Scaffold

Create `codex/journal/devonboarder_feedback_log.md` and use this format:

```markdown
# DevOnboarder Feedback Log

## ⭐️ Stars/Forks

- 2025-07-01 — ⭐️ by @user123 ("Fastest onboarding I’ve seen")
- 2025-07-02 — Forked by @opensourceguy (wants to add Go support)

## Issues/PRs

- 2025-07-03 — Issue #12: "Feature request: Slack integration" (@devteamlead)
- 2025-07-04 — PR #15: Fixed typo in journaling flow (@casualhacker)

## Mentions

- 2025-07-05 — Mentioned in r/selfhosted weekly thread
- 2025-07-06 — Shared in Indie Dev Discord "Tool of the Week"

## Testimonials

> "We got three remote interns up to speed in a day, instead of a week. Huge win." — @remoteteamops
```
