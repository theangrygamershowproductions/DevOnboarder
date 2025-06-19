# Feedback Dashboard PRD

This document defines the requirements for an internal dashboard that collects and surfaces community feedback.

## Objectives
- Centralize incoming reports from testers and founders.
- Provide maintainers with a clear view of bug reports and feature requests.
- Encourage transparency by showing progress on submitted items.

## Personas
- **Maintainer** – triages feedback and updates item status.
- **Alpha tester** – submits issues and monitors resolutions.
- **Founder** – reviews overall trends to steer the roadmap.

## Major Features
1. **Submission form** connected to the existing issue tracker.
2. **Status tracking** with states like "open", "in progress", and "closed".
3. **Analytics snapshot** summarizing the volume and type of feedback.

## Stretch Goals
- Real-time updates via WebSockets.
- OAuth login so testers can view their personal history.
- CSV export of all feedback metrics.
