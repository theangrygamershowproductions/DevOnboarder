# 📝 DevOnboarder Markdown Formatting Rules

Golden rules and best practices for writing lint-free markdown documentation in DevOnboarder.

## 🎯 Golden Rules for Lint-Free Markdown

The key to avoiding markdown linting errors is consistent spacing and structure.

### Essential Spacing Rules

The most important rules to follow:

1. **Headings:** Always surrounded by blank lines
2. **Lists:** Always surrounded by blank lines
3. **Code Blocks:** Always surrounded by blank lines
4. **Nested Lists:** Use 4 spaces for nesting
5. **No Trailing Spaces:** Except for line breaks (2 spaces)

### Style Consistency Rules

Additional formatting standards:

- **Emphasis:** Use asterisks, not underscores for _italic_ and **bold**
- **No Emphasis as Headings:** Don't use italics/bold as section headers
- **Reference Links:** Use descriptive text instead of "click here"

## 🛠️ Quick Fix Commands

Common markdown linting errors and their solutions.

### Spacing Fixes

The most frequent issues and corrections:

```bash
# Add blank line before heading
# Change: content\n## Heading
# To: content\n\n## Heading

# Add blank line after heading
# Change: ## Heading\ncontent
# To: ## Heading\n\ncontent

# Fix list spacing
# Change: text\n- item
# To: text\n\n- item\n\nmore text
```

### Indentation Fixes

Fix nested list indentation:

```bash
# Fix nested indentation
# Change: - item\n  - nested (2 spaces)
# To: - item\n    - nested (4 spaces)
```

## 🎯 Prevention Strategy

How to avoid markdown errors from the start.

### Use the Template Approach

Create new documents using the compliant template:

```bash
# Generate lint-free markdown from template
bash scripts/create_lint_perfect_md.sh "my-doc" "My Title" "Description"
```

### Validate While Writing

Check formatting as you work:

```bash
# Check current file for errors
markdownlint docs/my-file.md

# Auto-fix simple formatting issues
markdownlint --fix docs/my-file.md
```

## 📊 Approach Comparison

Reactive vs proactive markdown creation analysis.

### Time and Effort Analysis

| Approach      | Time Investment       | Error Rate | Frustration Level |
| ------------- | --------------------- | ---------- | ----------------- |
| **Reactive**  | Write + 15min fixes   | High       | 😤 High           |
| **Proactive** | Template + validation | Low        | 😌 Low            |

### Best Practice Workflow

The recommended process for creating markdown:

1. **Start with template:** Use `scripts/create_lint_perfect_md.sh`
2. **Follow spacing rules:** Blank lines around headings, lists, code blocks
3. **Use 4-space indentation:** For all nested list items
4. **Validate frequently:** Run linter during writing process
5. **Fix immediately:** Don't accumulate formatting debt

## Conclusion

Template-driven markdown creation eliminates formatting errors.

**Result:** Lint-free documentation from the start! ✨

---

Document generated using lint-compliant template
