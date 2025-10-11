#!/usr/bin/env bash
# Setup script for PR automation framework

set -euo pipefail

echo "BOT: Setting up PR Automation Framework"
echo "====================================="

# Create required directories
mkdir -p {logs,reports,tmp}
echo "SUCCESS: Created directories: logs, reports, tmp"

# Make all scripts executable
find scripts/ -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
echo "SUCCESS: Made all scripts executable"

# Create automation configuration
cat > .automation-config.json << 'EOF'
{
  "version": "1.0",
  "framework": "DevOnboarder PR Automation",
  "modes": {
    "analyze": "Analysis only - safe for all PRs",
    "execute": "Analysis + automated fixes",
    "full-auto": "Full automation including potential auto-merge"
  },
  "safety": {
    "protected_files": ["Potato.md", "*.key", "*.pem"],
    "protected_branches": ["main", "production"],
    "require_approval": true
  },
  "thresholds": {
    "auto_merge_health": 80,
    "auto_fix_health": 40,
    "abandon_threshold": 20
  }
}
EOF
echo "SUCCESS: Created automation configuration"

# Create automation alias
cat > scripts/pr-auto << 'EOF'
#!/usr/bin/env bash
# Quick alias for PR automation
bash scripts/automate_pr_process.sh "$@"
EOF
chmod +x scripts/pr-auto
echo "SUCCESS: Created pr-auto alias"

# Test basic dependencies
echo ""
echo "INFO: Checking dependencies..."

if command -v gh >/dev/null 2>&1; then
    echo "SUCCESS: GitHub CLI: Available"
else
    echo "WARNING:  GitHub CLI: Not found - may need installation"
fi

if command -v jq >/dev/null 2>&1; then
    echo "SUCCESS: jq: Available"
else
    echo "WARNING:  jq: Not found - may need installation"
fi

if command -v markdownlint >/dev/null 2>&1; then
    echo "SUCCESS: markdownlint: Available"
else
    echo "WARNING:  markdownlint: Not found - formatting fixes will be skipped"
fi

echo ""
echo "SUCCESS: PR Automation Framework setup complete!"
echo ""
echo "ACTION: Usage Examples:"
echo "  # Analyze PR #966"
echo "  bash scripts/automate_pr_process.sh 966 analyze"
echo ""
echo "  # Analyze + apply fixes"
echo "  bash scripts/automate_pr_process.sh 966 execute"
echo ""
echo "  # Full automation (careful!)"
echo "  bash scripts/automate_pr_process.sh 966 full-auto"
echo ""
echo "  # Quick alias"
echo "  bash scripts/pr-auto 966 analyze"
