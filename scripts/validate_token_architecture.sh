#!/bin/bash
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Source color utilities
source "/home/potato/TAGS/shared/scripts/color_utils.sh"
# Token Architecture v2.1 Validation Script
# Validates separation of CI/CD and runtime tokens across all environments
# FIXED: DevOnboarder ZERO TOLERANCE POLICY compliant

set -euo pipefail

# Initialize logging
mkdir -p logs
LOG_FILE="logs/$(basename "$0" .sh)_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Load tokens using Token Architecture v2.1 with developer guidance
# Note: This validation script only needs file access, not actual token values
if [ -f "scripts/enhanced_token_loader.sh" ]; then
    # shellcheck source=scripts/enhanced_token_loader.sh disable=SC1091
    source scripts/enhanced_token_loader.sh
elif [ -f "scripts/load_token_environment.sh" ]; then
    # shellcheck source=scripts/load_token_environment.sh disable=SC1091
    source scripts/load_token_environment.sh
fi

# Legacy fallback for development
if [ -f .env ]; then
    # shellcheck source=.env disable=SC1091
    source .env
fi

START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
printf "[%s] Starting Token Architecture v2.1 Validation\n" "$START_TIME"
printf "\n"

# Define token categories
CICD_TOKENS=(
    "AAR_TOKEN"
    "CI_BOT_TOKEN"
    "CI_ISSUE_AUTOMATION_TOKEN"
    "DEV_ORCHESTRATION_BOT_KEY"
    "PROD_ORCHESTRATION_BOT_KEY"
    "STAGING_ORCHESTRATION_BOT_KEY"
)

RUNTIME_TOKENS=(
    "DISCORD_BOT_TOKEN"
    "DISCORD_CLIENT_SECRET"
    "BOT_JWT"
    "CF_DNS_API_TOKEN"
    "TUNNEL_TOKEN"
)

# Define environments to check
ENVIRONMENTS=("" "dev" "ci" "prod")

printf "Validating token separation across environments:\n"
printf "\n"

# Check each environment
for env in "${ENVIRONMENTS[@]}"; do
    if [[ -z "$env" ]]; then
        env_name="default"
        env_file=".env"
        token_file=".tokens"
    else
        env_name="$env"
        env_file=".env.$env"
        token_file=".tokens.$env"
    fi

    printf "=== Environment: %s ===\n" "$env_name"

    # Check if environment file exists
    if [[ ! -f "$env_file" ]]; then
        printf "  Warning: %s not found\n" "$env_file"
        printf "\n"
        continue
    fi

    # Check if tokens file exists
    if [[ ! -f "$token_file" ]]; then
        printf "  Warning: %s not found\n" "$token_file"
        printf "\n"
        continue
    fi

    # Validate CI/CD tokens are in .tokens file
    printf "  CI/CD tokens in %s:\n" "$token_file"
    cicd_count=0
    for token in "${CICD_TOKENS[@]}"; do
        if grep -q "^${token}=" "$token_file" 2>/dev/null; then
            printf "    Found: %s\n" "$token"
            ((cicd_count++))
        fi
    done

    if [[ $cicd_count -eq 0 ]]; then
        printf "    Warning: No CI/CD tokens found in %s\n" "$token_file"
    else
        printf "    Total found: %d CI/CD tokens\n" "$cicd_count"
    fi

    # Validate runtime tokens are in .env file
    printf "  Runtime tokens in %s:\n" "$env_file"
    runtime_count=0
    for token in "${RUNTIME_TOKENS[@]}"; do
        if grep -q "^${token}=" "$env_file" 2>/dev/null; then
            printf "    Found: %s\n" "$token"
            ((runtime_count++))
        fi
    done

    if [[ $runtime_count -eq 0 ]]; then
        printf "    Warning: No runtime tokens found in %s\n" "$env_file"
    else
        printf "    Total found: %d runtime tokens\n" "$runtime_count"
    fi

    # Cross-contamination check
    printf "  Cross-contamination validation:\n"
    cross_contamination=false

    # Check for CI/CD tokens in .env (BAD)
    for token in "${CICD_TOKENS[@]}"; do
        if grep -q "^${token}=" "$env_file" 2>/dev/null; then
            printf "    ERROR: CI/CD token %s found in %s (should be in %s)\n" "$token" "$env_file" "$token_file"
            cross_contamination=true
        fi
    done

    # Check for runtime tokens in .tokens (BAD)
    for token in "${RUNTIME_TOKENS[@]}"; do
        if grep -q "^${token}=" "$token_file" 2>/dev/null; then
            printf "    ERROR: Runtime token %s found in %s (should be in %s)\n" "$token" "$token_file" "$env_file"
            cross_contamination=true
        fi
    done

    if [[ "$cross_contamination" == false ]]; then
        printf "    Clean separation - no cross-contamination detected\n"
    fi

    printf "\n"
done

# Environment-specific validation
printf "=== Environment-Specific Validation ===\n"
printf "\n"

# CI environment should have test values only
if [[ -f ".env.ci" ]]; then
    printf "Validating .env.ci for test values:\n"
    if grep -q "test\|placeholder\|mock\|ci_" ".env.ci" 2>/dev/null; then
        printf "  Confirmed: Contains test/placeholder values\n"
    else
        printf "  WARNING: May contain production values in CI environment\n"
    fi
    printf "\n"
fi

# Production environment security check
if [[ -f ".env.prod" ]]; then
    printf "Production environment security check:\n"
    if [[ -r ".env.prod" ]]; then
        printf "  INFO: Production environment file exists and is accessible\n"
        printf "  REMINDER: Ensure production secrets are properly secured\n"
    else
        printf "  INFO: Production environment file has restricted access\n"
    fi
    printf "\n"
fi

# Token Architecture v2.1 compliance summary
printf "=== Token Architecture v2.1 Compliance Summary ===\n"
printf "\n"

total_environments=0
compliant_environments=0

for env in "${ENVIRONMENTS[@]}"; do
    if [[ -z "$env" ]]; then
        env_name="default"
        env_file=".env"
        token_file=".tokens"
    else
        env_name="$env"
        env_file=".env.$env"
        token_file=".tokens.$env"
    fi

    if [[ -f "$env_file" && -f "$token_file" ]]; then
        total_environments=$((total_environments + 1))

        # Check for proper separation
        has_contamination=false

        for token in "${CICD_TOKENS[@]}"; do
            if grep -q "^${token}=" "$env_file" 2>/dev/null; then
                has_contamination=true
                break
            fi
        done

        for token in "${RUNTIME_TOKENS[@]}"; do
            if grep -q "^${token}=" "$token_file" 2>/dev/null; then
                has_contamination=true
                break
            fi
        done

        if [[ "$has_contamination" == false ]]; then
            compliant_environments=$((compliant_environments + 1))
            printf "Environment %s: COMPLIANT\n" "$env_name"
        else
            printf "Environment %s: NON-COMPLIANT (cross-contamination detected)\n" "$env_name"
        fi
    fi
done

printf "\n"
printf "Compliance Rate: %d/%d environments\n" "$compliant_environments" "$total_environments"

if [[ $compliant_environments -eq $total_environments ]] && [[ $total_environments -gt 0 ]]; then
    printf "STATUS: Token Architecture v2.1 fully compliant\n"
    printf "All environments maintain proper token separation\n"
    exit 0
elif [[ $compliant_environments -gt 0 ]]; then
    printf "STATUS: Partial compliance - some environments need fixes\n"
    printf "Review cross-contamination errors above\n"
    exit 1
else
    printf "STATUS: Non-compliant - immediate attention required\n"
    printf "Token Architecture v2.1 separation not implemented\n"
    exit 2
fi
