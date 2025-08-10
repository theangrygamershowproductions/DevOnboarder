#!/bin/bash

# AAR JSON Creation Helper
# Ensures schema_version is always included from the start
# Usage: ./scripts/create_aar_json.sh <title> <type> <priority>

set -e

# Validate inputs
if [ $# -lt 3 ]; then
    echo "Usage: $0 <title> <type> <priority>"
    echo "Types: Infrastructure, CI, Monitoring, Documentation, Feature, Security"
    echo "Priorities: Critical, High, Medium, Low"
    exit 1
fi

TITLE="$1"
TYPE="$2"
PRIORITY="$3"
DATE=$(date +%Y-%m-%d)

# Create filename (sanitized)
FILENAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_\|_$//g')
FILEPATH="docs/AAR/data/${FILENAME}.aar.json"

# Create JSON with required schema_version
cat > "$FILEPATH" << EOF
{
  "schema_version": "1.0.0",
  "title": "$TITLE",
  "date": "$DATE",
  "type": "$TYPE",
  "priority": "$PRIORITY",
  "executive_summary": {
    "problem": "Clear problem statement being addressed",
    "solution": "Solution approach taken to resolve the problem",
    "outcome": "Final result achieved and impact delivered"
  },
  "participants": [
    "@user (Product Owner)",
    "@github-copilot (Implementation Agent)"
  ],
  "phases": [
    {
      "name": "Planning",
      "duration": "1 week",
      "description": "Project planning and design phase",
      "status": "Completed"
    }
  ],
  "outcomes": {
    "success_metrics": [
      "Metric 1: Before → After"
    ],
    "challenges_overcome": [
      "Challenge overcome"
    ]
  },
  "follow_up": {
    "action_items": [
      {
        "task": "Complete documentation updates",
        "owner": "@platform-team",
        "due_date": "$(date -d '+7 days' +%Y-%m-%d)",
        "status": "Not Started"
      }
    ]
  },
  "lessons_learned": [
    "Key insight for organizational learning"
  ]
}
EOF

echo "SUCCESS AAR JSON template created: $FILEPATH"
echo "EDIT Schema version 1.0.0 automatically included"
echo "CONFIG Edit the file to add your specific content"
echo "DEPLOY Generate markdown with: node scripts/render_aar.js '$FILEPATH' docs/AAR/reports"
