# Issue Labeling Quick Reference

## Essential Labels for Every Issue

### Priority (Choose One)

- `priority-high` 🔴 - Critical infrastructure improvements
- `priority-medium` 🟡 - Significant developer experience improvements
- `priority-low` 🟢 - Nice-to-have enhancements

### Effort (Choose One)

- `effort-small` ⚡ - 1-2 day implementations
- `effort-medium` 🔧 - 3-5 day implementations
- `effort-large` 🏗️ - 1+ week implementations

### Component (Choose One or More)

- `testing-infrastructure` 🧪 - Test runners, coverage, artifacts
- `developer-experience` 👨‍💻 - Tooling, documentation, automation
- `security-enhancement` 🔒 - Authentication, vulnerabilities
- `cross-platform` 🌐 - Windows/macOS compatibility
- `performance` ⚡ - Speed and efficiency improvements

### Technology (Choose Relevant)

- `python` 🐍 - Python code and dependencies
- `javascript` 🟨 - JavaScript/TypeScript code
- `codex` 🤖 - DevOnboarder agent system

### Type (Choose One)

- `enhancement` ✨ - New features or improvements
- `bug` 🐛 - Something isn't working
- `documentation` 📚 - Doc updates and guides

## Quick Labeling Examples

**New Test Feature**: `priority-medium`, `effort-medium`, `testing-infrastructure`, `python`, `enhancement`

**Bug Fix**: `priority-high`, `effort-small`, `bug`, `python`

**Documentation Update**: `priority-low`, `effort-small`, `documentation`

**Performance Optimization**: `priority-medium`, `effort-medium`, `performance`, `python`, `enhancement`

## Common Filter Combinations

```bash
# High priority quick wins
is:open label:priority-high label:effort-small

# Testing improvements
is:open label:testing-infrastructure label:enhancement

# Developer experience enhancements
is:open label:developer-experience label:priority-medium
```

---

📖 **Full Guide**: [docs/contributing/issue-labeling-guide.md](issue-labeling-guide.md)
