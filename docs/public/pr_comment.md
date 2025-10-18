---
author: DevOnboarder Team

consolidation_priority: P3
content_uniqueness_score: 4
created_at: '2025-09-12'
description: Template and guidelines for DevOnboarder pull request comments and code review
document_type: template
merge_candidate: false
project: DevOnboarder
similarity_group: public-public
status: active
tags:

- pr

- comment

- template

- code-review

- guidelines

title: Pull Request Comment Template
updated_at: '2025-09-12'
visibility: internal
---

# Pull Request Comment Template

This document provides standardized templates and guidelines for pull request comments in the DevOnboarder project.

## Comment Templates

### Code Review Feedback

#### Positive Feedback

```markdown
 **Great work!** This implementation is clean and follows our coding standards.

## Highlights

- Excellent error handling

- Clear variable naming

- Proper test coverage

```bash

### Constructive Feedback

```markdown
 **Suggestion:** Consider refactoring this section for better readability.

## Recommendation

- Extract complex logic into separate functions

- Add inline comments for clarity

- Consider using more descriptive variable names

## Example

```python

# Current implementation

result = process_data(data, flag, config, user)

# Suggested improvement

processed_result = process_user_data(
    user_data=data,
    validation_enabled=flag,
    processing_config=config,
    current_user=user
)

```bash

## Critical Issues

```markdown

 **Critical Issue:** This change introduces a security vulnerability.

**Issue:** SQL injection risk in user input processing

**Impact:** Potential data breach and unauthorized access

**Required Action:** Implement parameterized queries before merge

## Resources

- [Security Guidelines](../security/README.md)

- [Safe Database Practices](../security/README.md)

```bash

### Testing Feedback

#### Test Coverage

```markdown

 **Test Coverage Review:**

**Current Coverage:** 94.2%

**Target Coverage:** 95%

## Missing Coverage

- Error handling in `process_payment()` function

- Edge cases in date validation logic

**Recommendation:** Add tests for uncovered code paths before merge.

```bash

### Test Quality

```markdown

🧪 **Test Quality Feedback:**

## Strengths

- Comprehensive happy path coverage

- Good use of mocking for external dependencies

- Clear test descriptions

## Improvements Needed

- Add edge case testing for boundary conditions

- Include negative test cases for error scenarios

- Consider adding integration tests for critical flows

```bash

### Documentation Feedback

#### Documentation Quality

```markdown

📚 **Documentation Review:**

## Strengths (2)

- Clear API documentation updates

- Good inline code comments

- Updated README with new features

## Missing

- Troubleshooting guide for new feature

- Configuration examples

- Migration instructions for breaking changes

```bash

### Documentation Compliance

```markdown

 **Documentation Compliance:**

**Status:**  Requires attention

## Issues

- Missing markdown linting compliance (MD022, MD032)

- API documentation not updated for new endpoints

- Change log entry missing

**Action Required:** Please update documentation to meet project standards.

```bash

### Performance Feedback

#### Performance Review

```markdown

FAST: **Performance Analysis:**

## Metrics

- Response time: 180ms (target: <200ms) 

- Memory usage: 15MB (acceptable) 

- Database queries: 2 queries (requires optimization) 

## Recommendations

- Consider query optimization for the new search feature

- Add database indexes for frequently accessed fields

```bash

### Architecture Feedback

#### Design Review

```markdown

BUILD: **Architecture Review:**

## Design Strengths

- Follows established patterns

- Maintains service boundaries

- Good separation of concerns

## Design Considerations

- Consider async processing for long-running operations

- Evaluate caching strategy for frequently accessed data

- Ensure proper error propagation across service boundaries

```bash

## Comment Guidelines

### Best Practices

1. **Be Constructive**

   - Focus on the code, not the person

   - Provide specific, actionable feedback

   - Suggest improvements with examples

   - Acknowledge good work and improvements

2. **Be Clear and Specific**

   - Use clear language and avoid ambiguity

   - Provide context for feedback

   - Include code examples when helpful

   - Reference relevant documentation or standards

3. **Prioritize Issues**

   - Mark critical issues that block merge

   - Distinguish between must-fix and nice-to-have

   - Use appropriate emoji and formatting for clarity

   - Provide estimated effort for suggested changes

### Comment Categories

#### 🔴 Blocking Issues

- Security vulnerabilities

- Breaking changes without migration

- Critical performance regressions

- Test failures or inadequate coverage

#### 🟡 Improvement Suggestions

- Code style and readability improvements

- Performance optimizations

- Documentation enhancements

- Architecture considerations

#### 🟢 Positive Feedback

- Recognition of good practices

- Appreciation of problem-solving approach

- Acknowledgment of code quality improvements

- Celebration of innovative solutions

### Response Guidelines

#### For PR Authors

1. **Acknowledge All Feedback**

   - Respond to each comment thread

   - Explain decisions and trade-offs

   - Ask clarifying questions when needed

   - Thank reviewers for their time

2. **Address Issues Systematically**

   - Fix blocking issues immediately

   - Plan improvement suggestions appropriately

   - Update tests and documentation as needed

   - Verify changes don't introduce new issues

3. **Communicate Changes**

   - Comment on what was changed and why

   - Push commits with clear commit messages

   - Request re-review after significant changes

   - Update PR description if scope changes

#### For Reviewers

1. **Follow-up on Feedback**

   - Verify that issues have been addressed

   - Re-review changed code thoroughly

   - Approve when all concerns are resolved

   - Provide final positive feedback

2. **Support the Author**

   - Offer to pair on complex changes

   - Provide additional resources when helpful

   - Escalate to team lead if needed

   - Celebrate successful completion

## Automated Comments

### CI/CD Integration

```markdown

🤖 **Automated CI/CD Report:**

**Build Status:**  Passed

**Test Coverage:** 96.2% ( Exceeds 95% requirement)

**Security Scan:**  No vulnerabilities found

**Documentation:**  All checks passed

## Performance Benchmarks

- API response time: 156ms ( Under 200ms target)

- Bundle size: 2.3KB ( Under 5KB limit)

- Memory usage: Stable ( No leaks detected)

```bash

### Quality Gate Results

```markdown

 **Quality Gate Results:**

| Check | Status | Details |

|-------|--------|---------|
| Code Coverage |  Pass | 96.2% (95% required) |
| Code Quality |  Pass | No critical issues |
| Security Scan |  Pass | 0 vulnerabilities |
| Documentation |  Warning | 2 minor formatting issues |

**Required Actions:** Fix documentation formatting before merge.

```bash

## Template Usage

### Quick Reference

- Use **** for positive feedback

- Use **** for suggestions and improvements

- Use **** for critical issues requiring fixes

- Use **** for metrics and coverage reports

- Use **BUILD:** for architectural discussions

- Use **📚** for documentation feedback

- Use **FAST:** for performance discussions

### Customization

Teams can customize these templates based on:

- Project-specific requirements

- Team communication preferences

- Technology stack considerations

- Quality standards and practices

This template system ensures consistent, constructive, and helpful code review communication across the DevOnboarder project.
