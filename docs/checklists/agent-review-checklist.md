---
similarity_group: checklists-checklists
content_uniqueness_score: 4
merge_candidate: false
consolidation_priority: P3
---
# Agent Review Checklist

## Purpose

This checklist ensures comprehensive review of AI agent interactions and outputs within the DevOnboarder project, maintaining quality and consistency with project standards.

## Pre-Review Setup

- [ ] Virtual environment activated (`source .venv/bin/activate`)
- [ ] Latest changes pulled from main branch
- [ ] Review context and requirements understood

## Code Quality Review

### Standards Compliance

- [ ] Follows DevOnboarder coding standards and patterns
- [ ] Implements proper error handling and validation
- [ ] Uses centralized utilities (timestamps, logging, etc.)
- [ ] Adheres to terminal output policy (no emojis, safe echo patterns)

### Architecture Alignment

- [ ] Consistent with existing service architecture
- [ ] Proper FastAPI patterns for backend services
- [ ] Appropriate TypeScript/ES module patterns for bot
- [ ] React component standards for frontend

## Documentation Review

### Content Quality

- [ ] Documentation is clear and comprehensive
- [ ] All internal links are valid and functional
- [ ] Examples are accurate and tested
- [ ] Follows markdown formatting standards

### Integration

- [ ] Proper cross-references to related documentation
- [ ] Consistent with existing documentation structure
- [ ] Updates related documentation when necessary

## Testing & Validation

### Automated Testing

- [ ] All tests pass with required coverage thresholds
- [ ] New functionality includes appropriate tests
- [ ] Test patterns follow project conventions

### Quality Gates

- [ ] QC validation passes (95% threshold)
- [ ] Pre-commit hooks execute successfully
- [ ] CI/CD pipeline validation complete

## Security & Safety

### Policy Compliance

- [ ] Enhanced Potato Policy compliance verified
- [ ] No sensitive information exposed
- [ ] Proper secret management patterns used

### Access Control

- [ ] Appropriate authentication/authorization implemented
- [ ] Service-to-service communication secured
- [ ] Environment-specific configurations handled correctly

## Final Verification

### Functionality

- [ ] Feature works as intended in development environment
- [ ] Integration with existing services validated
- [ ] Performance impact assessed and acceptable

### Documentation

- [ ] README and setup instructions updated if needed
- [ ] API documentation reflects changes
- [ ] Migration guides provided for breaking changes

## Sign-off

- [ ] All checklist items completed
- [ ] Ready for integration into main branch
- [ ] Documentation and tests support long-term maintenance

---

**Note**: This checklist should be used in conjunction with automated quality gates and not as a replacement for thorough testing and validation procedures.
