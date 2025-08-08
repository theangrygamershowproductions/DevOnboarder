# Smart Markdown Fixing

DevOnboarder implements "Quiet Reliability" philosophy for markdown documentation through intelligent auto-fixing that goes beyond basic `markdownlint --fix` capabilities.

## The Problem

Standard markdownlint auto-fixing fails on common patterns that humans obviously intend:

```markdown

# Example: Obvious bash command without language tag

```bash

npm install express
echo "Hello World"

```bash

**Issue**: Tool requires manual specification of `bash` language, even though the content is obviously shell commands.

## The Solution

DevOnboarder's intelligent markdown fixer uses context-aware pattern recognition to handle obvious cases automatically:

### Pattern Recognition

| Language | Detection Patterns |
|----------|-------------------|
| `bash` | `npm install`, `git clone`, `echo "`, `./scripts/`, `# Comments` |
| `python` | `def function()`, `import module`, `class Name`, `@decorator` |
| `javascript` | `const x =`, `function name()`, `console.log()`, `=> {` |
| `typescript` | `interface Name`, `type Alias =`, `: Promise<`, `async function` |
| `json` | `{` at start, `"key": value` patterns |
| `yaml` | `key:`, `- list items`, `version: 1.0` |
| `dockerfile` | `FROM image`, `RUN command`, `COPY source dest` |

### Emphasis-to-Heading Conversion

Automatically converts obvious emphasis to proper headings:

```markdown

**Port Already in Use**        →    #### Port Already in Use
**Dependencies Missing**       →    #### Dependencies Missing

```text

Context-aware heading level selection:
- If followed by code block or list → `####` (subheading)
- Otherwise → `###` (section heading)

### Spacing Auto-Fix

Adds required blank lines around:
- Headings (MD022)
- Code blocks (MD031)
- Lists (MD032)

## Usage

### Command Line

```bash

# Fix all markdown files

make markdown-fix

# Fix specific file

make markdown-fix-single FILE=docs/README.md

# Direct script usage

./scripts/smart_markdown_fix.sh "**/*.md"
./scripts/smart_markdown_fix.sh app/aar-ui/README.md

# Dry run (show what would change)

python scripts/intelligent_markdown_fixer.py --dry-run "**/*.md"

```text

### Integration with DevOnboarder Workflow

The smart markdown fixer integrates seamlessly with existing DevOnboarder infrastructure:

1. **Pre-commit Integration**: Available for developers who want intelligent auto-fixing
2. **Make Targets**: `make markdown-fix` for project-wide fixes
3. **CI Enhancement**: Can be integrated into auto-fix workflows
4. **Manual Workflow**: Use when pre-commit hooks fail on markdown

### Three-Stage Process

The smart fixer uses a three-stage approach:

```bash

# Stage 1: Intelligent pattern recognition

python scripts/intelligent_markdown_fixer.py "$@"

# Stage 2: Standard markdownlint auto-fix

npx markdownlint-cli2 --fix "$@"

# Stage 3: Final validation

npx markdownlint-cli2 "$@"

```text

## Examples

### Before Smart Fixing

```markdown

#### Port Already in Use

```text

lsof -i :3001

```text

### After Smart Fixing

```markdown

#### Port Already in Use

```bash

lsof -i :3001

```yaml

### Language Detection in Action

Input:

```markdown

```bash

npm install express
git clone repo
echo "Setup complete"

```

```yaml

Output:

```markdown

```bash

npm install express
git clone repo
echo "Setup complete"

```text

```text

## Benefits

### For Developers

- **Reduced Manual Work**: No more manually adding `bash` to obvious shell commands
- **Context Awareness**: Tool understands document structure for heading levels
- **Consistent Output**: Automated compliance with DevOnboarder markdown standards

### For the Project

- **Quiet Reliability**: Documentation fixes happen automatically without developer intervention
- **Quality Maintenance**: Ensures consistent markdown quality across all documentation
- **Reduced Friction**: Removes common pain points from documentation workflow

### For AI Agents

- **Intelligent Defaults**: Agents can create documentation knowing obvious patterns will be auto-fixed
- **Reduced Error Cycles**: Fewer iterations needed to achieve markdown compliance
- **Context Preservation**: Maintains document intent while fixing formatting

## Technical Architecture

### Pattern Detection Engine

The `IntelligentMarkdownFixer` class uses regular expression patterns matched against code content to determine appropriate language tags:

```python

self.language_patterns = {
    'bash': [
        r'npm (install|run|test|start|build)',
        r'pip install',
        r'git (clone|add|commit|push)',

        # ... more patterns

    ],
    'python': [
        r'def \w+\(',
        r'class \w+',
        r'import \w+',

        # ... more patterns

    ],
}

```

### Scoring Algorithm

- Analyzes first 5 lines of code blocks
- Scores each potential language based on pattern matches
- Selects highest-scoring language
- Falls back to safe defaults for ambiguous cases

### Safety Features

- **Conservative Defaults**: Unknown patterns default to `text`
- **Non-Destructive**: Only adds missing language tags, doesn't change existing ones
- **Validation Integration**: Works with existing markdownlint configuration

## Future Enhancements

### Planned Features

- **Import Detection**: Recognize module imports to distinguish JavaScript vs TypeScript
- **Command Context**: Understand multi-line command context for better bash detection
- **Configuration File**: Allow project-specific pattern customization
- **IDE Integration**: VSCode extension for real-time intelligent fixing

### Integration Opportunities

- **Pre-commit Hook**: Optional intelligent pre-processing before standard markdownlint
- **CI Auto-fix**: Automated PR creation for documentation improvements
- **Documentation Generation**: Auto-fix generated documentation during build

## Contributing

To extend pattern recognition:

1. Add patterns to `language_patterns` dictionary in `scripts/intelligent_markdown_fixer.py`
2. Test with representative code samples
3. Ensure patterns don't conflict with existing languages
4. Update documentation with new detection capabilities

## DevOnboarder Philosophy Alignment

This tool embodies DevOnboarder's "Quiet Reliability" philosophy:

- **Works Quietly**: Fixes obvious issues without requiring user intervention
- **Works Reliably**: Conservative pattern matching prevents false positives
- **Serves Those Who Need It**: Reduces friction for documentation maintenance

The smart markdown fixer represents how tooling should evolve: understanding human intent and reducing manual overhead while maintaining quality standards.
