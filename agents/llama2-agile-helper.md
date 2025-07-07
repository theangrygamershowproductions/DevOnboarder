# Llama2 Agile Helper Agent
**Status:** Planned.

**Purpose:** Offers agile planning suggestions and coaching using the Llama2 language model.

**Inputs:** Developer questions and project metrics.

**Outputs:** Sprint guidance and backlog grooming tips.

## Environment Variables

- `LLAMA2_API_KEY` – API key for calling the Llama2 service.


## Planned Workflows

| Workflow | Description |
| -------- | ----------- |
| Sprint Planning | Break down epics into user stories, estimate story points, flag ambiguous tickets |
| Daily Standups | Summarize team updates, detect blockers, highlight progress |
| Retrospectives | Analyze retro notes, extract themes, suggest improvements |
| Backlog Grooming | Classify stale tickets, suggest grouping or refactoring |
| Agile Coaching | Provide tips or nudges when processes drift |

## Prompt Templates

Prompt files live in the `prompts/` folder.

| Template | Input Data | Output |
| -------- | ---------- | ------ |
| `sprint_estimator.prompt` | Epics, stories, team history | Story point estimates |
| `standup_summary.prompt`  | Team update logs | Bullet summary, blockers |
| `retro_analysis.prompt`   | Raw retro notes | Summary, lessons learned |
| `ticket_classifier.prompt` | Backlog items | Priority, labels |
| `coaching_tips.prompt`    | Sprint metrics, WIP ratio | Process suggestions |

## Integration Points

| Integration Point | Description |
| ----------------- | ----------- |
| Codex Task Hook | Generate sprint summaries after each sprint |
| Slack/Teams Trigger | Invoke `/retro-summary` or `/groom-backlog` in chat |
| GitHub Action Hook | Run on PRs labeled `planning` or `retrospective` |
| Frontend Button | Manual trigger in the dashboard |

## Metrics

Metrics are logged in `metrics/llama2-usage.md`.
- Number of agent invocations
- Time saved vs. manual planning (estimation)
- Ticket classification accuracy
- Team satisfaction via periodic polls
