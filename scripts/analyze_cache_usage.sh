#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"

# DevOnboarder Cache Analysis and Management Script
# Purpose: Analyze GitHub Actions cache usage patterns and provide optimization recommendations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging setup
SCRIPT_DIR=$(dirname "$0")
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cache_analysis_$(date +%Y%m%d_%H%M%S).log"

# Redirect output to both console and log file
exec > >(tee -a "$LOG_FILE") 2>&1

echo "DevOnboarder Cache Analysis - $(date)"
echo "Log file: $LOG_FILE"
echo "=========================================="

# Function to calculate cache sizes
analyze_cache_usage() {
    echo -e "${BLUE}Analyzing current cache usage..."

    # Get cache data with error handling
    if ! gh cache list --json id,key,sizeInBytes,createdAt,lastAccessedAt,ref > cache_data.json 2>/dev/null; then
        echo -e "${RED}Error: Failed to retrieve cache data. Please ensure you have proper GitHub CLI authentication."
        exit 1
    fi

    # Calculate total size
    total_bytes=$(jq -r '.[].sizeInBytes' cache_data.json | awk '{sum+=$1} END {print sum}')
    total_gb=$(echo "scale=2; $total_bytes / 1024 / 1024 / 1024" | bc)
    total_mb=$(echo "scale=0; $total_bytes / 1024 / 1024" | bc)

    echo -e "${YELLOW}Total Cache Usage: ${total_gb} GB (${total_mb} MB)"

    # Analyze cache patterns
    echo -e "${BLUE}Cache Pattern Analysis:"

    # Playwright caches
    playwright_count=$(jq -r '.[] | select(.key | contains("playwright")) | .key' cache_data.json | wc -l)
    playwright_size=$(jq -r '.[] | select(.key | contains("playwright")) | .sizeInBytes' cache_data.json | awk '{sum+=$1} END {print sum/1024/1024}' | bc 2>/dev/null || echo "0")

    # Python caches
    python_count=$(jq -r '.[] | select(.key | contains("py3.") or contains("python")) | .key' cache_data.json | wc -l)
    python_size=$(jq -r '.[] | select(.key | contains("py3.") or contains("python")) | .sizeInBytes' cache_data.json | awk '{sum+=$1} END {print sum/1024/1024}' | bc 2>/dev/null || echo "0")

    # Node.js caches
    node_count=$(jq -r '.[] | select(.key | contains("node")) | .key' cache_data.json | wc -l)
    node_size=$(jq -r '.[] | select(.key | contains("node")) | .sizeInBytes' cache_data.json | awk '{sum+=$1} END {print sum/1024/1024}' | bc 2>/dev/null || echo "0")

    echo "  Playwright Caches: $playwright_count entries (~${playwright_size} MB)"
    echo "  Python Caches: $python_count entries (~${python_size} MB)"
    echo "  Node.js Caches: $node_count entries (~${node_size} MB)"

    # Warning if approaching limit
    if (( $(echo "$total_gb > 8.0" | bc -l) )); then
        echo -e "${RED}WARNING:  WARNING: Cache usage is approaching 10GB limit!"
    elif (( $(echo "$total_gb > 6.0" | bc -l) )); then
        debug_msg "  CAUTION: Cache usage is high. Consider cleanup."
    else
        success_msg " Cache usage is within acceptable limits."
    fi
}

# Function to identify duplicate/stale caches
identify_cleanup_candidates() {
    echo -e "${BLUE}Identifying cleanup candidates..."

    # Find caches older than 7 days
    echo "Caches older than 7 days:"
    stale_caches=$(jq -r --arg cutoff "$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" '.[] | select(.createdAt < $cutoff) | .id' cache_data.json)
    stale_count=$(echo "$stale_caches" | grep -c . 2>/dev/null || echo "0")

    if [ "$stale_count" -gt 0 ]; then
        echo "  Found $stale_count stale caches"
        stale_size=$(jq -r --arg cutoff "$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)" '.[] | select(.createdAt < $cutoff) | .sizeInBytes' cache_data.json | awk '{sum+=$1} END {print sum/1024/1024}' | bc 2>/dev/null || echo "0")
        echo "  Stale cache size: ~${stale_size} MB"
    else
        echo "  No stale caches found (older than 7 days)"
    fi

    # Find potential duplicate caches (same key pattern but different hashes)
    echo ""
    echo "Potential duplicate cache patterns:"
    jq -r '.[] | .key' cache_data.json | sed 's/-[a-f0-9]\{40,\}.*$//' | sort | uniq -c | sort -nr | head -10
}

# Function to provide optimization recommendations
provide_recommendations() {
    echo -e "${BLUE}Cache Optimization Recommendations:"

    # Check if total usage is problematic
    total_bytes=$(jq -r '.[].sizeInBytes' cache_data.json | awk '{sum+=$1} END {print sum}')
    total_gb=$(echo "scale=2; $total_bytes / 1024 / 1024 / 1024" | bc)

    if (( $(echo "$total_gb > 7.0" | bc -l) )); then
        echo -e "${RED}🚨 IMMEDIATE ACTION REQUIRED:"
        echo "1. Run emergency cache cleanup: gh workflow run cache-cleanup.yml -f cleanup_type=all-old-caches"
        echo "2. Review and optimize cache keys to reduce duplication"
        echo "3. Implement more aggressive cache retention policies"
    fi

    echo -e "${GREEN}General Recommendations:"
    echo "1. The new cache-cleanup.yml workflow will automatically clean PR caches"
    echo "2. Run periodic manual cleanups: gh workflow run cache-cleanup.yml -f cleanup_type=stale-caches"
    echo "3. Consider optimizing Playwright cache keys to reduce size"
    echo "4. Review Python pip cache strategies for better hit rates"
    echo "5. Monitor cache usage with this script weekly"

    # Specific recommendations based on patterns
    playwright_count=$(jq -r '.[] | select(.key | contains("playwright")) | .key' cache_data.json | wc -l)
    if [ "$playwright_count" -gt 10 ]; then
        echo -e "${YELLOW}Playwright Optimization:"
        echo "  - Consider using more specific cache keys to reduce browser re-downloads"
        echo "  - Implement cache sharing between similar test environments"
    fi
}

# Function to run emergency cleanup
emergency_cleanup() {
    echo -e "${RED}EMERGENCY: Running immediate cache cleanup..."

    if ! command -v gh >/dev/null 2>&1; then
        echo -e "${RED}Error: GitHub CLI not found. Please install gh CLI first."
        exit 1
    fi

    # Get oldest 20 caches
    oldest_caches=$(jq -r 'sort_by(.createdAt) | .[0:20] | .[].id' cache_data.json)

    if [ -z "$oldest_caches" ]; then
        echo "No caches found for cleanup"
        return
    fi

    echo "Deleting oldest 20 caches..."
    deleted_count=0

    for cache_id in $oldest_caches; do
        if gh cache delete "$cache_id" 2>/dev/null; then
            echo "Deleted cache: $cache_id"
            deleted_count=$((deleted_count + 1))
        else
            echo "Failed to delete cache: $cache_id"
        fi
    done

    echo -e "${GREEN}Emergency cleanup completed. Deleted $deleted_count caches."
}

# Main execution
main() {
    case "${1:-analyze}" in
        "analyze")
            analyze_cache_usage
            identify_cleanup_candidates
            provide_recommendations
            ;;
        "emergency")
            analyze_cache_usage
            emergency_cleanup
            ;;
        "help")
            echo "Usage: $0 [analyze|emergency|help]"
            echo "  analyze   - Analyze current cache usage (default)"
            echo "  emergency - Run immediate cleanup of oldest caches"
            echo "  help      - Show this help message"
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac

    # Cleanup temporary files
    rm -f cache_data.json
}

# Check dependencies
if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}Error: jq is required but not installed. Please install jq first."
    exit 1
fi

if ! command -v bc >/dev/null 2>&1; then
    echo -e "${RED}Error: bc is required but not installed. Please install bc first."
    exit 1
fi

# Run main function with all arguments
main "$@"
