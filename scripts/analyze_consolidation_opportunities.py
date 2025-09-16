#!/usr/bin/env python3
"""
Priority Matrix Consolidation Analysis
Identifies consolidation opportunities using Priority Matrix metadata.
"""

import frontmatter
import os
import json
from collections import defaultdict


def analyze_consolidation_opportunities():
    """Analyze Priority Matrix data for consolidation opportunities."""

    # Scan for markdown files with Priority Matrix fields
    merge_candidates = []
    similarity_groups = defaultdict(list)
    low_uniqueness = []

    for root, dirs, files in os.walk("."):
        # Skip backup directories and .git
        dirs[:] = [
            d for d in dirs if not d.startswith(".") and "backup" not in d.lower()
        ]

        for file in files:
            if file.endswith(".md"):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        post = frontmatter.load(f)

                    # Extract Priority Matrix fields
                    merge_candidate = post.metadata.get("merge_candidate", False)
                    similarity_group = post.metadata.get("similarity_group", "unknown")
                    uniqueness_score = post.metadata.get("content_uniqueness_score", 5)
                    consolidation_priority = post.metadata.get(
                        "consolidation_priority", "P3"
                    )

                    file_info = {
                        "file": file_path,
                        "merge_candidate": merge_candidate,
                        "similarity_group": similarity_group,
                        "content_uniqueness_score": uniqueness_score,
                        "consolidation_priority": consolidation_priority,
                        "title": post.metadata.get("title", file),
                    }

                    # Group files for analysis
                    similarity_groups[similarity_group].append(file_info)

                    if merge_candidate:
                        merge_candidates.append(file_info)

                    if uniqueness_score <= 2:
                        low_uniqueness.append(file_info)

                except Exception:
                    continue

    # Generate consolidation report
    report = {
        "summary": {
            "total_files_analyzed": sum(
                len(group) for group in similarity_groups.values()
            ),
            "merge_candidates": len(merge_candidates),
            "low_uniqueness_files": len(low_uniqueness),
            "similarity_groups": len(similarity_groups),
        },
        "consolidation_opportunities": {
            "immediate_merge_candidates": sorted(
                merge_candidates, key=lambda x: x["consolidation_priority"]
            ),
            "low_uniqueness_review": sorted(
                low_uniqueness, key=lambda x: x["content_uniqueness_score"]
            ),
            "largest_similarity_groups": sorted(
                [
                    (group, len(files))
                    for group, files in similarity_groups.items()
                    if len(files) > 3
                ],
                key=lambda x: x[1],
                reverse=True,
            ),
        },
        "recommended_actions": [],
    }

    # Generate recommendations
    if merge_candidates:
        report["recommended_actions"].append(
            {
                "action": "automated_consolidation",
                "priority": "P1",
                "description": (
                    f"Process {len(merge_candidates)} files flagged for merging"
                ),
                "files": [f["file"] for f in merge_candidates[:5]],  # Top 5
            }
        )

    if low_uniqueness:
        report["recommended_actions"].append(
            {
                "action": "uniqueness_review",
                "priority": "P2",
                "description": (
                    f"Review {len(low_uniqueness)} files with low uniqueness scores"
                ),
                "files": [f["file"] for f in low_uniqueness[:5]],  # Top 5
            }
        )

    return report


if __name__ == "__main__":
    report = analyze_consolidation_opportunities()
    print(json.dumps(report, indent=2))
