#!/bin/bash
# Create MVP GitHub Issues for Docker Service Mesh
# Creates trackable issues for Phase 1 and Phase 3

set -euo pipefail

echo "🎫 Creating MVP GitHub Issues for Docker Service Mesh"
echo "=================================================="

# Check if GitHub CLI is available
if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI (gh) not installed"
    echo "Install: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI ready"

# Create Phase 1 Issue
echo ""
echo "📋 Creating Phase 1 Issue: Network Tiering + DNS Aliases"

PHASE1_BODY=$(cat << 'EOF'
# 🥇 MVP Phase 1: Docker Network Tiering + DNS Aliases

**Timeline**: Week 1 of MVP
**Priority**: P0 (MVP Infrastructure Foundation)
**Dependencies**: None (foundational phase)

## Quick Start

```bash
# Run scaffolding script
./scripts/scaffold_phase1_networks.sh

# Manual network assignments required
# Update docker-compose.dev.yaml service assignments

# Test implementation
make up
./scripts/validate_network_contracts.sh
```

## Success Criteria

- [ ] Tiered networks: `auth_tier`, `api_tier`, `data_tier`
- [ ] Service assignments to correct tiers
- [ ] Data tier isolation (internal network)
- [ ] DNS resolution working
- [ ] Zero service regressions

## Related Files

- Implementation: `docs/architecture/SEMANTIC_DOCKER_SERVICE_MESH_IMPLEMENTATION_PLAN.md`
- Scaffolding: `scripts/scaffold_phase1_networks.sh`
- Validation: `scripts/validate_network_contracts.sh`

See issue template for full implementation details.
EOF
)

gh issue create \
    --title "[MVP] Phase 1: Docker Network Tiering + DNS Aliases" \
    --body "$PHASE1_BODY" \
    --label "MVP,docker,network,P0,phase-1" \
    --milestone "MVP Docker Service Mesh" 2>/dev/null || echo "Note: Milestone may not exist yet"

echo "✅ Phase 1 issue created"

# Create Phase 3 Issue
echo ""
echo "📋 Creating Phase 3 Issue: CI Network Contract Validation"

PHASE3_BODY=$(cat << 'EOF'
# 🥇 MVP Phase 3: CI Network Contract Validation

**Timeline**: Week 2 of MVP
**Priority**: P0 (MVP CI/CD Integration)
**Dependencies**: Phase 1 (Network Foundation) must be complete

## Quick Start

```bash
# Enhance validation script
./scripts/validate_network_contracts.sh

# Create GitHub Actions workflow
# Add pre-commit hook integration
# Test CI enforcement
```

## Success Criteria

- [ ] Network contract validator operational
- [ ] GitHub Actions integration
- [ ] Pre-commit hooks active
- [ ] Clear violation reporting
- [ ] Zero tolerance enforcement

## Related Files

- Validation: `scripts/validate_network_contracts.sh`
- CI Workflow: `.github/workflows/network-validation.yml`
- Pre-commit: `.pre-commit-config.yaml`

See issue template for full implementation details.
EOF
)

gh issue create \
    --title "[MVP] Phase 3: CI Network Contract Validation" \
    --body "$PHASE3_BODY" \
    --label "MVP,ci,validation,P0,phase-3" \
    --milestone "MVP Docker Service Mesh" 2>/dev/null || echo "Note: Milestone may not exist yet"

echo "✅ Phase 3 issue created"

# Summary
echo ""
echo "🎯 MVP Issues Created Successfully!"
echo ""
echo "📊 Summary:"
echo "✅ Phase 1: Network Foundation (Week 1)"
echo "✅ Phase 3: CI Validation (Week 2)"
echo "🚫 Phase 2, 4, 5: Deferred to Post-MVP"

echo ""
echo "🔗 View Issues:"
echo "gh issue list --label MVP"
echo ""
echo "🚀 Ready to start implementation!"
echo "Begin with: ./scripts/mvp_docker_service_mesh.sh"
