---
author: DevOnboarder Team
consolidation_priority: P1
content_uniqueness_score: 5
created_at: '2025-10-12'
description: Comprehensive token expiry monitoring system documentation with setup, usage, and troubleshooting guides
document_type: documentation
merge_candidate: false
project: DevOnboarder
similarity_group: token-expiry-monitoring-docs
status: active
tags:
- monitoring
- security
- automation
- documentation
title: Token Expiry Monitoring System
updated_at: '2025-10-12'
visibility: internal
version: 1.0
---

# Token Expiry Monitoring System

## Overview

The Token Expiry Monitoring System provides comprehensive automated monitoring and notification capabilities for token expiry across the DevOnboarder ecosystem. This system integrates with DevOnboarder's existing token architecture (TOKEN_ARCHITECTURE_V2.1.md) and provides proactive alerts for infrastructure teams about upcoming token rotations.

**Key Features:**
- 🔍 **Multi-layered Monitoring**: Interactive, automated, and scheduled monitoring options
- 🔔 **Intelligent Notifications**: Critical, warning, and informational alerts via multiple channels
- 🔗 **DevOnboarder Integration**: Native integration with existing token_loader.py system
- 📊 **Comprehensive Reporting**: Detailed expiry analysis with actionable insights
- 🛡️ **Security-First**: Zero-tolerance token exposure with masking and audit trails
- ⚡ **VS Code Integration**: Seamless development workflow integration
- 🔄 **90→45 Day Migration**: Planned support for shorter expiry cycles

## Goal & Context

**Primary Goal**: Implement automated token expiry monitoring to prevent service disruptions from expired tokens while maintaining security through proactive rotation planning.

**Business Context**: DevOnboarder operates with multiple token types (CI/CD, runtime, maintainer) that require regular rotation. Manual monitoring has proven unreliable, leading to service disruptions. This system provides automated monitoring with intelligent notifications to infrastructure teams.

**Technical Context**: Integrates with existing token_loader.py system, follows DevOnboarder security patterns, and provides multi-channel notifications for different severity levels.

## Requirements & Constraints

**Functional Requirements**:
- Monitor all token categories (CI/CD, Runtime, Maintainer)
- Provide configurable notification thresholds
- Generate comprehensive expiry reports
- Support interactive and automated monitoring modes
- Integrate with DevOnboarder token architecture

**Security Constraints**:
- Zero-tolerance for token value exposure
- Audit trail for all monitoring activities
- Secure token storage validation
- Access control based on user permissions

**Performance Constraints**:
- Minimal system resource usage
- Configurable monitoring frequency
- Background operation without UI blocking
- Efficient token validation algorithms

## Use Cases

### Daily Infrastructure Monitoring
**Actor**: Infrastructure Team Member
**Goal**: Monitor token health as part of daily operations
**Steps**:
1. Run morning status check via VS Code task
2. Review critical alerts in notifications directory
3. Generate weekly reports for planning
4. Address expiring tokens before deadline

### Emergency Response
**Actor**: On-call Infrastructure Engineer
**Goal**: Respond to critical token expiry alerts
**Steps**:
1. Receive notification via configured channel
2. Assess impact using detailed token analysis
3. Execute emergency rotation procedures
4. Update monitoring system with new token details

### Compliance Auditing
**Actor**: Security Team Member
**Goal**: Verify token rotation compliance
**Steps**:
1. Generate compliance reports
2. Review audit trails for rotation activities
3. Validate security configurations
4. Update policies based on findings

## Dependencies

**Core Dependencies**:
- `token_loader.py` - DevOnboarder token management system
- `bash` - Shell scripting environment
- `python3` - Python runtime for advanced features
- `curl` - HTTP client for notifications
- `mail` - Email client for notifications

**Optional Dependencies**:
- `jq` - JSON processing for advanced reports
- `slack` - Slack webhook integration
- `cron` - System scheduling for automation

**System Requirements**:
- Ubuntu 24.04 LTS or compatible Linux distribution
- 100MB free disk space for logs and reports
- Network access for external notifications
- User permissions for token file access

## Architecture Integration

This system leverages DevOnboarder's established token management patterns:

- **CI/CD Tokens**: Repository-level automation tokens (90-day expiry)
- **Runtime Tokens**: Service-dependent tokens (typically no expiry)
- **Maintainer Tokens**: External PR intervention tokens (90-day expiry)

### System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   VS Code IDE   │────│  Token Monitor   │────│  Token Loader   │
│   (Tasks)       │    │  (Bash/Python)  │    │  (Python)       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Interactive   │    │   Notifications  │    │   Token Store   │
│   Dashboard     │────│   (GitHub/Slack) │────│   (.tokens)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Scheduler     │    │   Reports        │    │   Audit Logs    │
│   (Cron)        │────│   (Markdown)     │────│   (JSON)        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Components

### 1. Token Expiry Monitor (`token_expiry_monitor.sh`)
Bash-based interactive monitoring tool with comprehensive reporting capabilities.

**Core Capabilities:**
- Interactive menu-driven interface
- Multi-category token monitoring (CI/CD, Runtime, Maintainer)
- Infrastructure team notifications with escalation paths
- Comprehensive expiry reports with trend analysis
- Direct integration with DevOnboarder token_loader.py
- Color-coded output with severity indicators
- Export capabilities (JSON, CSV, Markdown)

**Key Functions:**
- `check_token_expiry()`: Calculates days until expiry with timezone handling
- `generate_notification()`: Creates actionable alerts for infrastructure team
- `generate_expiry_report()`: Produces detailed status reports
- `monitor_category()`: Category-specific monitoring logic
- `interactive_menu()`: User-friendly command interface

### 2. Token Expiry Integrator (`token_expiry_integrator.py`)
Python-based advanced monitoring with deep DevOnboarder integration.

**Advanced Features:**
- Direct integration with token_loader.py API
- Detailed expiry analysis with historical trends
- Automated notification scheduling with retry logic
- JSON output for CI/CD pipeline integration
- Comprehensive error handling and recovery
- Performance metrics and monitoring statistics
- Token usage pattern analysis

**Key Classes:**
- `TokenExpiryIntegrator`: Main integration class
- `TokenMonitor`: Real-time monitoring capabilities
- `NotificationManager`: Multi-channel notification handling
- `ReportGenerator`: Advanced report generation with analytics

### 3. Token Expiry Scheduler (`token_expiry_scheduler.sh`)
Automated scheduling system for continuous monitoring.

**Automation Features:**
- Cron-based scheduling with flexible intervals
- Background daemon operation with process management
- Configurable notification channels (Email, Slack, GitHub)
- Health monitoring and automatic recovery
- Log rotation and retention policies
- Resource usage optimization

**Scheduling Options:**
- **Continuous Monitoring**: Every 6 hours (default)
- **Daily Reports**: Business hours summary
- **Weekly Deep Analysis**: Monday morning comprehensive review
- **Critical Alerts**: Immediate notification for <7 days

### 4. VS Code Tasks Integration (`.vscode/tasks.json`)
Seamless integration with DevOnboarder's development workflow.

**Available Tasks (15 total):**
- **Token Expiry: Monitor All** - Complete ecosystem monitoring
- **Token Expiry: Generate Report** - Comprehensive status report
- **Token Expiry: Check CI/CD Tokens** - CI/CD token focus
- **Token Expiry: Check Runtime Tokens** - Runtime token focus
- **Token Expiry: Check Maintainer Tokens** - Maintainer token focus
- **Token Expiry: Interactive Monitor** - Launch interactive dashboard
- **Token Expiry: Python Integration Check** - Advanced Python monitoring
- **Token Expiry: Python Report Generation** - Detailed analytics
- **Token Expiry: Scheduler Status** - Check automation status
- **Token Expiry: Start Scheduler** - Begin automated monitoring
- **Token Expiry: Stop Scheduler** - Halt automated monitoring
- **Token Expiry: Run Immediate Cycle** - Manual trigger monitoring
- **Token Expiry: Interactive Scheduler** - Scheduler management menu
- **Token Expiry: Check Single Token** - Individual token analysis
- **Token Expiry: Full Monitoring Cycle** - Complete cycle with notifications

## Quick Start

### Prerequisites

Ensure you have access to DevOnboarder's token infrastructure:

```bash
# Verify token_loader.py is available
python3 scripts/token_loader.py validate EXTERNAL_PR_MAINTAINER_TOKEN

# Check token storage directories exist
ls -la ~/.config/devonboarder/maintainer_tokens/
```

## Quick Start

### Prerequisites

Ensure you have access to DevOnboarder's token infrastructure:

```bash
# Verify token_loader.py is available
cd ~/TAGS/ecosystem/DevOnboarder
python3 scripts/token_loader.py validate EXTERNAL_PR_MAINTAINER_TOKEN

# Check token storage directories exist
ls -la ~/.config/devonboarder/maintainer_tokens/

# Verify notification directories
mkdir -p reports notifications logs
```

### Installation & Setup

#### 1. Verify System Requirements
```bash
# Check bash version (4.0+ required)
bash --version

# Verify Python 3.8+
python3 --version

# Check required tools
which curl mail  # For notifications
```

#### 2. Initial Configuration
```bash
# Create scheduler configuration
cat > ~/.token_scheduler.conf << 'EOF'
# Monitoring schedule (cron format)
MONITOR_SCHEDULE="0 */6 * * *"

# Report generation schedule
REPORT_SCHEDULE="0 9 * * 1"

# Notification settings
ENABLE_NOTIFICATIONS=true
NOTIFICATION_EMAIL="infra@tags-devsecops.com"
NOTIFICATION_SLACK_WEBHOOK="https://hooks.slack.com/..."

# Infrastructure contacts
INFRA_TEAM="@theangrygamershowproductions/infrastructure"
DEVSECOPS_TEAM="@tags-devsecops"

# Monitoring thresholds
CRITICAL_THRESHOLD=7
WARNING_THRESHOLD=30
INFO_THRESHOLD=45
EOF
```

#### 3. Test Integration
```bash
# Test token loader integration
python3 scripts/token_expiry_integrator.py check --token TEST_TOKEN --type maintainer --json

# Test basic monitoring
./scripts/token_expiry_monitor.sh monitor-all
```

### Basic Usage

#### Interactive Monitoring
```bash
# Launch interactive monitor (recommended for first-time users)
./scripts/token_expiry_monitor.sh

# Or use VS Code Task: "Token Expiry: Interactive Monitor"
```

**Interactive Menu Options:**
```
Token Expiry Monitoring System v1.0.0
=====================================

1. Monitor All Tokens          - Complete ecosystem check
2. Monitor CI/CD Tokens        - Repository automation tokens
3. Monitor Runtime Tokens      - Service-dependent tokens
4. Monitor Maintainer Tokens   - External PR tokens
5. Generate Report             - Create detailed status report
6. Check Single Token          - Analyze specific token
7. View Notifications          - Show recent alerts
8. System Status               - Health and configuration check
9. Exit

Select option (1-9):
```

#### Quick Status Checks
```bash
# Check all tokens with summary output
./scripts/token_expiry_monitor.sh monitor-all

# Check specific category
./scripts/token_expiry_monitor.sh maintainer-only
./scripts/token_expiry_monitor.sh cicd-only
./scripts/token_expiry_monitor.sh runtime-only

# Generate comprehensive report
./scripts/token_expiry_monitor.sh report
```

#### Python Integration Examples
```bash
# Advanced monitoring with DevOnboarder integration
python3 scripts/token_expiry_integrator.py monitor

# Check specific token with detailed output
python3 scripts/token_expiry_integrator.py check \
  --token EXTERNAL_PR_MAINTAINER_TOKEN \
  --type maintainer \
  --verbose

# Generate detailed JSON report
python3 scripts/token_expiry_integrator.py report --format json

# Run monitoring cycle with notifications
python3 scripts/token_expiry_integrator.py cycle --notify
```

#### Single Token Analysis
```bash
# Check specific maintainer token
./scripts/token_expiry_monitor.sh check-token EXTERNAL_PR_MAINTAINER_TOKEN maintainer

# Check CI/CD token
./scripts/token_expiry_monitor.sh check-token AAR_TOKEN cicd

# With detailed output
./scripts/token_expiry_monitor.sh check-token EXTERNAL_PR_MAINTAINER_TOKEN maintainer --verbose
```

### Automated Scheduling

#### Start Background Monitoring
```bash
# Start automated scheduler (runs every 6 hours by default)
./scripts/token_expiry_scheduler.sh start

# Or use VS Code Task: "Token Expiry: Start Scheduler"
```

#### Custom Scheduling
```bash
# Start with custom schedule (every 4 hours)
MONITOR_SCHEDULE="0 */4 * * *" ./scripts/token_expiry_scheduler.sh start

# Start with immediate first run
./scripts/token_expiry_scheduler.sh start --immediate
```

#### Scheduler Management
```bash
# Check scheduler status
./scripts/token_expiry_scheduler.sh status

# Stop scheduler
./scripts/token_expiry_scheduler.sh stop

# Restart scheduler
./scripts/token_expiry_scheduler.sh restart

# View scheduler logs
./scripts/token_expiry_scheduler.sh logs
```

### VS Code Integration

#### Running Tasks
Access via **Terminal → Run Task** or **Ctrl+Shift+P → "Tasks: Run Task"**:

**Common Tasks:**
- **Token Expiry: Monitor All** - Complete ecosystem monitoring
- **Token Expiry: Generate Report** - Create comprehensive report
- **Token Expiry: Interactive Monitor** - Launch interactive dashboard
- **Token Expiry: Start Scheduler** - Begin automated monitoring

**Advanced Tasks:**
- **Token Expiry: Python Integration Check** - Advanced analytics
- **Token Expiry: Full Monitoring Cycle** - Complete cycle with notifications
- **Token Expiry: Check Single Token** - Individual token analysis

## Monitoring Thresholds

| Severity | Days Until Expiry | Action Required |
|----------|------------------|-----------------|
| Critical | < 7 days | Immediate rotation required |
| Warning | 7-30 days | Plan rotation soon |
| Info | 30-45 days | Monitor closely |
| Healthy | > 45 days | No action needed |

## Token Categories

### CI/CD Tokens (90-day expiry)
- `AAR_TOKEN`
- `CI_BOT_TOKEN`
- `CI_ISSUE_AUTOMATION_TOKEN`
- `DEV_ORCHESTRATION_BOT_KEY`
- `PROD_ORCHESTRATION_BOT_KEY`
- `STAGING_ORCHESTRATION_BOT_KEY`

### Runtime Tokens (Service-dependent)
- `DISCORD_BOT_TOKEN`
- `DISCORD_CLIENT_SECRET`
- `BOT_JWT`
- `CF_DNS_API_TOKEN`
- `TUNNEL_TOKEN`

### Maintainer Tokens (90-day expiry)
- `EXTERNAL_PR_MAINTAINER_TOKEN`
- `SECURITY_AUDIT_TOKEN`
- `EMERGENCY_OVERRIDE_TOKEN`

## Notification System

### Automatic Alerts
The system generates notifications for:
- **Critical**: Tokens expiring within 7 days
- **Warning**: Tokens expiring within 30 days
- **Expired**: Tokens that have already expired

### Notification Channels
- **GitHub Issues**: Critical alerts create infrastructure issues
- **Email**: Configurable email notifications
- **Slack**: Webhook-based Slack notifications
- **Local Files**: Markdown notifications in `notifications/` directory

### Infrastructure Team Contacts
- Primary: `@theangrygamershowproductions/infrastructure`
- Secondary: `@tags-devsecops`

## Output Locations

### Reports
- Location: `reports/token_expiry_report_*.md`
- Frequency: On-demand or scheduled
- Content: Comprehensive status across all token categories

### Notifications
- Location: `notifications/token_expiry_alert_*.md`
- Trigger: Critical expiry conditions detected
- Content: Actionable alerts for infrastructure team

### Logs
- Location: `logs/token_expiry_integrator.log`
- Content: Detailed monitoring activity and errors
- Retention: Configurable log rotation

## VS Code Integration

### Available Tasks
Run these via **Terminal → Run Task** or **Ctrl+Shift+P → "Tasks: Run Task"**:

- **Token Expiry: Monitor All** - Check all token categories
- **Token Expiry: Generate Report** - Create comprehensive report
- **Token Expiry: Check CI/CD Tokens** - CI/CD tokens only
- **Token Expiry: Check Runtime Tokens** - Runtime tokens only
- **Token Expiry: Check Maintainer Tokens** - Maintainer tokens only
- **Token Expiry: Interactive Monitor** - Launch interactive menu
- **Token Expiry: Python Integration Check** - Advanced Python monitoring
- **Token Expiry: Python Report Generation** - Detailed Python reports
- **Token Expiry: Scheduler Status** - Check scheduler status
- **Token Expiry: Start Scheduler** - Start automated monitoring
- **Token Expiry: Stop Scheduler** - Stop automated monitoring
- **Token Expiry: Run Immediate Cycle** - Run monitoring cycle now
- **Token Expiry: Interactive Scheduler** - Launch scheduler menu
- **Token Expiry: Check Single Token** - Check specific token
- **Token Expiry: Full Monitoring Cycle** - Complete cycle with notifications

## Configuration Files

### Scheduler Configuration (`~/.token_scheduler.conf`)
```bash
# Monitoring schedule (cron format)
MONITOR_SCHEDULE="0 */6 * * *"

# Report generation schedule
REPORT_SCHEDULE="0 9 * * 1"

# Notification settings
ENABLE_NOTIFICATIONS=true
NOTIFICATION_EMAIL="infra@tags-devsecops.com"
NOTIFICATION_SLACK_WEBHOOK="https://hooks.slack.com/..."

# Infrastructure contacts
INFRA_TEAM="@theangrygamershowproductions/infrastructure"
DEVSECOPS_TEAM="@tags-devsecops"

# Monitoring thresholds
CRITICAL_THRESHOLD=7
WARNING_THRESHOLD=30
INFO_THRESHOLD=45
```

### Token Storage
- **CI/CD Tokens**: `.tokens` file (gitignored)
- **Runtime Tokens**: `.env` file (gitignored)
- **Maintainer Tokens**: `~/.config/devonboarder/maintainer_tokens/` (encrypted)

## Security Considerations

### Token Masking
- All token values are automatically masked in output
- Follows DevOnboarder security guidelines
- Zero-tolerance policy for token exposure

### Access Control
- Scheduler runs with user permissions
- No elevated privileges required
- Secure token storage with proper file permissions

### Audit Trail
- All monitoring activities logged
- Notification creation tracked
- Error conditions recorded

## Troubleshooting

### Common Issues & Solutions

#### 🔍 "token_loader.py not found"
**Symptoms:** Import errors when running Python integrator
```bash
# Error message
ModuleNotFoundError: No module named 'token_loader'
```

**Solutions:**
```bash
# Ensure you're in the correct directory
cd ~/TAGS/ecosystem/DevOnboarder

# Verify script exists and is executable
ls -la scripts/token_loader.py

# Check Python path and test import
python3 -c "import sys; sys.path.append('.'); from scripts.token_loader import TokenLoader; print('Import successful')"

# Test basic functionality
python3 scripts/token_loader.py validate TEST_TOKEN
```

#### 🔒 "Permission denied on token files"
**Symptoms:** Access errors when reading token storage
```bash
# Error message
Permission denied: .tokens
```

**Solutions:**
```bash
# Check current permissions
ls -la .tokens .env ~/.config/devonboarder/maintainer_tokens/

# Fix permissions (600 for security)
chmod 600 .tokens .env

# For maintainer tokens directory
chmod 700 ~/.config/devonboarder/maintainer_tokens/
chmod 600 ~/.config/devonboarder/maintainer_tokens/*

# Verify ownership
chown $USER:$USER .tokens .env
```

#### ⏰ "Scheduler not starting"
**Symptoms:** Scheduler fails to start or shows errors
```bash
# Error message
Failed to start token expiry scheduler
```

**Solutions:**
```bash
# Check for existing process
./scripts/token_expiry_scheduler.sh status

# Kill any existing processes
pkill -f token_expiry_scheduler.sh

# Clean up PID file if exists
rm -f .token_scheduler.pid

# Check system resources
df -h  # Disk space
free -h  # Memory

# Start with verbose logging
DEBUG=true ./scripts/token_expiry_scheduler.sh start

# Check logs for errors
tail -f logs/token_scheduler.log
```

#### 📢 "Notifications not sending"
**Symptoms:** Monitoring works but no alerts are received
```bash
# No notification files created
ls notifications/
```

**Solutions:**
```bash
# Verify configuration file exists
cat ~/.token_scheduler.conf

# Test notification configuration
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test notification"}' \
  $NOTIFICATION_SLACK_WEBHOOK

# Check email configuration
echo "Test email" | mail -s "Test Subject" $NOTIFICATION_EMAIL

# Test notification generation manually
./scripts/token_expiry_monitor.sh monitor-all --notify

# Check notification directory permissions
ls -la notifications/
```

#### 🐍 "Python integration fails"
**Symptoms:** Python scripts fail with import or runtime errors
```bash
# Error message
ImportError: cannot import name 'validate_required_tokens'
```

**Solutions:**
```bash
# Check token_loader.py API
python3 -c "from scripts.token_loader import TokenLoader; help(TokenLoader.validate_required_tokens)"

# Verify Python version compatibility
python3 --version  # Should be 3.8+

# Check for syntax errors
python3 -m py_compile scripts/token_expiry_integrator.py

# Test with debug mode
DEBUG=true python3 scripts/token_expiry_integrator.py monitor
```

#### 📊 "Reports not generating"
**Symptoms:** Monitoring runs but no report files created
```bash
# Reports directory empty
ls reports/
```

**Solutions:**
```bash
# Check directory permissions
ls -la reports/

# Create directory if missing
mkdir -p reports

# Test report generation manually
./scripts/token_expiry_monitor.sh report

# Check disk space
df -h reports/

# Verify write permissions
touch reports/test.txt && rm reports/test.txt
```

### Debug Mode & Logging

#### Enable Debug Logging
```bash
# For bash scripts
export TOKEN_MONITOR_DEBUG=true
./scripts/token_expiry_monitor.sh monitor-all

# For Python integrator
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
python3 -c "import logging; logging.basicConfig(level=logging.DEBUG)"
python3 scripts/token_expiry_integrator.py monitor

# For scheduler
DEBUG=true ./scripts/token_expiry_scheduler.sh start
```

#### Log File Locations
```bash
# Main monitoring logs
tail -f logs/token_monitor.log

# Python integrator logs
tail -f logs/token_expiry_integrator.log

# Scheduler logs
tail -f logs/token_scheduler.log

# System logs (if configured)
tail -f /var/log/syslog | grep token
```

#### Log Analysis Commands
```bash
# Search for errors in last 24 hours
grep -h "ERROR" logs/*.log | tail -20

# Find warning patterns
grep -r "WARNING" logs/

# Check for token exposure incidents
grep -i "token.*value" logs/*.log

# Monitor notification success/failure
grep -E "(NOTIFICATION|SUCCESS|FAILED)" logs/token_scheduler.log
```

### Performance Issues

#### High CPU Usage
```bash
# Monitor process usage
ps aux | grep token_expiry

# Check system load
uptime
top -p $(pgrep -f token_expiry_scheduler.sh)

# Adjust monitoring frequency
# Edit ~/.token_scheduler.conf
MONITOR_SCHEDULE="0 */12 * * *"  # Reduce to every 12 hours
```

#### Memory Issues
```bash
# Check memory usage
ps aux --sort=-%mem | head -10

# Monitor for memory leaks
watch -n 60 'ps aux | grep token_expiry'

# Restart services if needed
./scripts/token_expiry_scheduler.sh restart
```

#### Disk Space Issues
```bash
# Check disk usage
df -h

# Monitor log file sizes
du -sh logs/ reports/ notifications/

# Clean old logs (keep last 30 days)
find logs/ -name "*.log" -mtime +30 -delete
find reports/ -name "*.md" -mtime +30 -delete
```

### Recovery Procedures

#### Emergency Stop
```bash
# Stop all monitoring processes
./scripts/token_expiry_scheduler.sh stop
pkill -f token_expiry_monitor.sh
pkill -f token_expiry_integrator.py

# Clean up PID files
rm -f .token_scheduler.pid
```

#### System Reset
```bash
# Stop all services
./scripts/token_expiry_scheduler.sh stop

# Clear logs (optional)
rm -f logs/token_*.log

# Reset configuration to defaults
rm ~/.token_scheduler.conf

# Restart fresh
./scripts/token_expiry_scheduler.sh start
```

#### Data Recovery
```bash
# Backup current state
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz logs/ reports/ notifications/

# Restore from backup
tar -xzf backup_*.tar.gz

# Verify integrity
./scripts/token_expiry_monitor.sh monitor-all
```

## API Reference

### Python Integration API

#### TokenExpiryIntegrator Class

**Main integration class for advanced token monitoring.**

```python
from scripts.token_expiry_integrator import TokenExpiryIntegrator

# Initialize integrator
integrator = TokenExpiryIntegrator()

# Monitor all tokens
results = integrator.monitor_all_tokens()

# Check specific token
status = integrator.check_token_expiry("EXTERNAL_PR_MAINTAINER_TOKEN", "maintainer")

# Generate reports
report = integrator.generate_expiry_report(format="json")
```

**Key Methods:**
- `monitor_all_tokens()` → Dict: Complete ecosystem monitoring
- `check_token_expiry(token_name, token_type)` → Dict: Individual token analysis
- `generate_expiry_report(format="markdown")` → str: Formatted report generation
- `run_monitoring_cycle(notify=True)` → bool: Full monitoring cycle with notifications
- `get_token_expiry_info(token_name, token_type)` → Dict: Detailed token metadata

#### TokenMonitor Class

**Real-time monitoring capabilities.**

```python
from scripts.token_expiry_integrator import TokenMonitor

monitor = TokenMonitor()

# Continuous monitoring
monitor.start_continuous_monitoring(interval_hours=6)

# Single monitoring cycle
results = monitor.perform_monitoring_cycle()

# Health check
health = monitor.check_system_health()
```

#### NotificationManager Class

**Multi-channel notification handling.**

```python
from scripts.token_expiry_integrator import NotificationManager

notifier = NotificationManager()

# Send critical alert
notifier.send_critical_alert("Token expiring in 3 days", token_name="AAR_TOKEN")

# Send weekly report
notifier.send_weekly_report(report_data)

# Test notification channels
notifier.test_notifications()
```

### Bash Script API

#### token_expiry_monitor.sh Commands

**Command-line interface for token monitoring.**

```bash
# Interactive mode
./scripts/token_expiry_monitor.sh

# Direct commands
./scripts/token_expiry_monitor.sh monitor-all
./scripts/token_expiry_monitor.sh maintainer-only
./scripts/token_expiry_monitor.sh report

# Single token check
./scripts/token_expiry_monitor.sh check-token TOKEN_NAME TOKEN_TYPE [--verbose]
```

**Exit Codes:**
- `0`: Success
- `1`: General error
- `2`: Token not found
- `3`: Permission denied
- `4`: Configuration error

#### token_expiry_scheduler.sh Commands

**Scheduler management interface.**

```bash
# Service management
./scripts/token_expiry_scheduler.sh start [--immediate]
./scripts/token_expiry_scheduler.sh stop
./scripts/token_expiry_scheduler.sh restart
./scripts/token_expiry_scheduler.sh status

# Monitoring
./scripts/token_expiry_scheduler.sh logs
./scripts/token_expiry_scheduler.sh monitor
```

### Configuration API

#### Scheduler Configuration Schema

**Configuration file format (`~/.token_scheduler.conf`):**

```bash
# Schedule Configuration
MONITOR_SCHEDULE="0 */6 * * *"        # Cron format
REPORT_SCHEDULE="0 9 * * 1"          # Weekly on Monday

# Notification Configuration
ENABLE_NOTIFICATIONS=true
NOTIFICATION_EMAIL="infra@tags-devsecops.com"
NOTIFICATION_SLACK_WEBHOOK="https://hooks.slack.com/..."

# Team Configuration
INFRA_TEAM="@theangrygamershowproductions/infrastructure"
DEVSECOPS_TEAM="@tags-devsecops"

# Threshold Configuration
CRITICAL_THRESHOLD=7                  # Days
WARNING_THRESHOLD=30                  # Days
INFO_THRESHOLD=45                     # Days

# System Configuration
LOG_RETENTION_DAYS=30
MAX_LOG_SIZE_MB=100
DEBUG_MODE=false
```

## Advanced Configuration

### Custom Thresholds

#### Environment-Specific Thresholds
```bash
# Production environment (stricter thresholds)
cat > ~/.token_scheduler.conf << EOF
CRITICAL_THRESHOLD=3
WARNING_THRESHOLD=14
INFO_THRESHOLD=30
EOF

# Development environment (relaxed thresholds)
cat > ~/.token_scheduler.dev.conf << EOF
CRITICAL_THRESHOLD=14
WARNING_THRESHOLD=45
INFO_THRESHOLD=75
EOF
```

#### Token-Type-Specific Thresholds
```bash
# High-security tokens (stricter)
HIGH_SECURITY_TOKENS="AAR_TOKEN,EXTERNAL_PR_MAINTAINER_TOKEN"
HIGH_SECURITY_CRITICAL=3
HIGH_SECURITY_WARNING=14

# Standard tokens (normal)
STANDARD_CRITICAL=7
STANDARD_WARNING=30
```

### Multi-Environment Support

#### Environment Detection
```bash
# Automatic environment detection
if [[ "$CI" == "true" ]]; then
    export TOKEN_ENV="ci"
elif [[ "$PRODUCTION" == "true" ]]; then
    export TOKEN_ENV="prod"
else
    export TOKEN_ENV="dev"
fi

# Load environment-specific config
source ~/.token_scheduler.${TOKEN_ENV}.conf
```

#### Environment-Specific Notifications
```bash
# Production notifications
PROD_NOTIFICATION_EMAIL="infra-prod@tags-devsecops.com"
PROD_SLACK_WEBHOOK="https://hooks.slack.com/services/PROD/..."

# Development notifications
DEV_NOTIFICATION_EMAIL="dev-team@tags-devsecops.com"
DEV_SLACK_WEBHOOK="https://hooks.slack.com/services/DEV/..."
```

### Integration with External Systems

#### CI/CD Pipeline Integration
```yaml
# .github/workflows/token-monitoring.yml
name: Token Expiry Monitoring
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Monitor Token Expiry
        run: |
          cd ecosystem/DevOnboarder
          ./scripts/token_expiry_integrator.py monitor --ci
```

#### Slack Integration Setup
```bash
# Create Slack webhook
# 1. Go to https://api.slack.com/apps
# 2. Create new app for workspace
# 3. Add "Incoming Webhooks" feature
# 4. Create webhook for target channel
# 5. Copy webhook URL to configuration

# Test webhook
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Token monitoring test"}' \
  "$NOTIFICATION_SLACK_WEBHOOK"
```

#### Email Integration Setup
```bash
# Configure system email
sudo apt-get install mailutils  # Ubuntu/Debian
# or
sudo yum install mailx          # CentOS/RHEL

# Configure SMTP (example for Gmail)
cat >> ~/.mailrc << EOF
set smtp=smtp.gmail.com:587
set smtp-auth=login
set smtp-auth-user=your-email@gmail.com
set smtp-auth-password=your-app-password
set ssl-verify=ignore
EOF

# Test email
echo "Test message" | mail -s "Test Subject" recipient@example.com
```

## Migration Guide

### From Manual Monitoring to Automated System

#### Phase 1: Assessment (Week 1)
```bash
# Assess current token landscape
./scripts/token_expiry_monitor.sh monitor-all --report

# Document current rotation processes
# Review existing notification methods
# Identify infrastructure team contacts
```

#### Phase 2: Pilot Implementation (Week 2)
```bash
# Start with non-critical tokens
./scripts/token_expiry_monitor.sh maintainer-only --notify

# Test notification channels
./scripts/token_expiry_scheduler.sh start --dry-run

# Validate reports and alerts
```

#### Phase 3: Full Deployment (Week 3)
```bash
# Enable full monitoring
./scripts/token_expiry_scheduler.sh start

# Configure production notifications
# Set up alerting for infrastructure team

# Monitor system performance
watch -n 300 './scripts/token_expiry_monitor.sh status'
```

#### Phase 4: Optimization (Week 4)
```bash
# Adjust thresholds based on feedback
# Optimize monitoring frequency
# Fine-tune notification content

# Train infrastructure team on new system
```

### 90-Day to 45-Day Expiry Migration

#### Preparation Phase
```bash
# Update configuration for new thresholds
cat > ~/.token_scheduler.conf << EOF
TARGET_EXPIRY=45
CRITICAL_THRESHOLD=5
WARNING_THRESHOLD=15
INFO_THRESHOLD=25
EOF

# Test with new thresholds
./scripts/token_expiry_monitor.sh monitor-all --test-thresholds
```

#### Gradual Rollout
```bash
# Phase 1: Warning adjustments (45-day tokens)
# Phase 2: Critical threshold reduction (30-day tokens)
# Phase 3: Full 45-day implementation

# Monitor impact on alert frequency
./scripts/token_expiry_monitor.sh report --trend-analysis
```

#### Process Updates
```bash
# Update rotation documentation
# Train team on accelerated schedule
# Adjust notification templates
# Update dashboard thresholds
```

### Legacy System Decommission

#### Data Migration
```bash
# Export legacy monitoring data
./scripts/token_expiry_monitor.sh export-legacy-data

# Import into new system
python3 scripts/token_expiry_integrator.py import-legacy-data legacy_export.json
```

#### Team Training
```bash
# Documentation updates
# Process documentation
# Emergency procedures
# Contact information updates
```

## Performance Metrics

### System Performance

#### Monitoring Metrics
```bash
# Check monitoring performance
time ./scripts/token_expiry_monitor.sh monitor-all

# Monitor resource usage
./scripts/token_expiry_monitor.sh monitor-all &
MONITOR_PID=$!
watch -n 5 "ps -p $MONITOR_PID -o pid,ppid,cmd,%cpu,%mem"
kill $MONITOR_PID
```

#### Scheduler Performance
```bash
# Monitor scheduler resource usage
./scripts/token_expiry_scheduler.sh status --performance

# Check log processing time
grep "Monitoring cycle completed" logs/token_scheduler.log | tail -10
```

### Alert Effectiveness

#### Notification Metrics
```bash
# Track notification success rate
grep -c "NOTIFICATION.*SUCCESS" logs/token_scheduler.log
grep -c "NOTIFICATION.*FAILED" logs/token_scheduler.log

# Calculate response times
# Monitor alert-to-action times
```

#### Token Rotation Metrics
```bash
# Track rotation completion times
# Monitor expiry prediction accuracy
# Calculate mean time to rotation
```

### Quality Metrics

#### System Reliability
```bash
# Monitor system uptime
uptime

# Check error rates
grep -c "ERROR" logs/*.log

# Track successful monitoring cycles
grep -c "Monitoring cycle completed" logs/token_scheduler.log
```

#### Data Quality
```bash
# Validate token data accuracy
./scripts/token_expiry_monitor.sh validate-data

# Check report completeness
./scripts/token_expiry_monitor.sh audit-reports
```

## Examples & Use Cases

### Daily Infrastructure Monitoring

#### Morning Status Check
```bash
# Infrastructure team's daily routine
cd ~/TAGS/ecosystem/DevOnboarder

# Quick status overview
./scripts/token_expiry_monitor.sh monitor-all

# Generate daily report
./scripts/token_expiry_monitor.sh report

# Check for critical alerts
ls -la notifications/ | grep $(date +%Y-%m-%d)
```

#### Weekly Review Process
```bash
# Monday morning comprehensive review
./scripts/token_expiry_monitor.sh report --weekly

# Review upcoming expirations
./scripts/token_expiry_monitor.sh monitor-all --focus-expiring

# Plan rotation schedule
./scripts/token_expiry_monitor.sh generate-rotation-plan
```

### Development Workflow Integration

#### Pre-Deployment Checks
```bash
# Before major deployments
cd ~/TAGS/ecosystem/DevOnboarder

# Verify token health
python3 scripts/token_expiry_integrator.py monitor --ci

# Check for expiring tokens that might affect deployment
./scripts/token_expiry_monitor.sh cicd-only --critical-only
```

#### CI/CD Pipeline Integration
```yaml
# .github/workflows/pre-deployment.yml
name: Pre-Deployment Token Check
on:
  pull_request:
    branches: [ main, develop ]

jobs:
  token-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check Token Expiry Status
        run: |
          cd ecosystem/DevOnboarder
          python3 scripts/token_expiry_integrator.py monitor --ci --fail-on-critical
```

### Emergency Response Scenarios

#### Critical Token Expiry Alert
```bash
# When critical alert is received

# Immediate assessment
./scripts/token_expiry_monitor.sh monitor-all --critical-only

# Identify affected systems
./scripts/token_expiry_monitor.sh check-token AAR_TOKEN cicd --impact-analysis

# Generate emergency rotation plan
./scripts/token_expiry_monitor.sh emergency-plan AAR_TOKEN
```

#### System Compromise Response
```bash
# In case of suspected token compromise

# Immediate isolation
./scripts/token_expiry_scheduler.sh emergency-stop

# Audit token usage
./scripts/token_expiry_monitor.sh audit-logs --last-24h

# Generate security report
./scripts/token_expiry_monitor.sh security-report
```

### Automated Operations

#### Cron-Based Monitoring
```bash
# System cron configuration
# Edit /etc/cron.d/token-monitoring
*/6 * * * * devonboarder /home/potato/TAGS/ecosystem/DevOnboarder/scripts/token_expiry_scheduler.sh run-cycle
0 9 * * 1 devonboarder /home/potato/TAGS/ecosystem/DevOnboarder/scripts/token_expiry_monitor.sh report --email
```

#### Log Rotation
```bash
# Logrotate configuration
# /etc/logrotate.d/token-monitoring
/home/potato/TAGS/ecosystem/DevOnboarder/logs/*.log {
    daily
    rotate 30
    compress
    missingok
    notifempty
    create 644 devonboarder devonboarder
    postrotate
        /home/potato/TAGS/ecosystem/DevOnboarder/scripts/token_expiry_scheduler.sh reload-logs
    endscript
}
```

### Custom Reporting

#### Executive Summary Report
```bash
# Generate executive summary
./scripts/token_expiry_monitor.sh report --executive --format pdf

# Monthly compliance report
./scripts/token_expiry_monitor.sh report --monthly --compliance

# Trend analysis report
./scripts/token_expiry_monitor.sh report --trends --last-90-days
```

#### Custom Notification Templates
```bash
# Create custom notification template
cat > notifications/custom_template.md << 'EOF'
# 🚨 Token Expiry Alert

**Token:** {{TOKEN_NAME}}
**Type:** {{TOKEN_TYPE}}
**Days Until Expiry:** {{DAYS_LEFT}}
**Severity:** {{SEVERITY}}

## Action Required
{{ACTION_REQUIRED}}

## Rotation Timeline
{{ROTATION_TIMELINE}}

## Contact
Infrastructure Team: @theangrygamershowproductions/infrastructure
EOF

# Use custom template
./scripts/token_expiry_monitor.sh notify --template custom_template.md
```

## Security & Compliance

### Security Audit Procedures

#### Regular Security Audits
```bash
# Monthly security audit
./scripts/token_expiry_monitor.sh security-audit

# Check for token exposure incidents
./scripts/token_expiry_monitor.sh audit-exposure

# Validate security configurations
./scripts/token_expiry_monitor.sh security-validation
```

#### Compliance Reporting
```bash
# Generate compliance reports
./scripts/token_expiry_monitor.sh compliance-report --soc2

# Audit trail review
./scripts/token_expiry_monitor.sh audit-trail --last-quarter

# Security incident response
./scripts/token_expiry_monitor.sh incident-report INCIDENT_ID
```

### Access Control

#### Role-Based Access
```bash
# Infrastructure team access
INFRA_USERS="infra-team-lead,security-officer"
INFRA_PERMISSIONS="read,write,notify,rotate"

# Development team access
DEV_USERS="dev-team-lead"
DEV_PERMISSIONS="read,monitor"

# Audit team access
AUDIT_USERS="compliance-officer"
AUDIT_PERMISSIONS="read,audit,report"
```

#### Audit Logging
```bash
# All actions are logged
tail -f logs/token_monitor.log

# Audit trail queries
./scripts/token_expiry_monitor.sh audit-log --user $USER --action monitor

# Compliance reporting
./scripts/token_expiry_monitor.sh audit-report --date-range 2024-01-01:2024-12-31
```

## Support & Resources

### Documentation Resources
- [TOKEN_ARCHITECTURE_V2.1.md](../docs/TOKEN_ARCHITECTURE_V2.1.md) - Token architecture details
- [TOKEN_SECURITY_GUIDELINES.md](../docs/TOKEN_SECURITY_GUIDELINES.md) - Security guidelines
- [DevOnboarder README.md](../README.md) - Main project documentation
- [AGENTS.md](../../AGENTS.md) - AI agent guidelines

### Infrastructure Team Contacts
- **Primary Contact**: `@theangrygamershowproductions/infrastructure`
- **Security Contact**: `@tags-devsecops`
- **Emergency Contact**: Create GitHub issue with `infrastructure` and `security` labels

### Emergency Procedures
1. **Critical Token Expiry** (< 7 days): Immediate rotation required
2. **System Compromise**: Isolate affected systems, audit logs, rotate tokens
3. **Monitoring Failure**: Check system resources, restart services, validate configuration
4. **Notification Failure**: Verify webhook URLs, check email configuration, test manually

### Getting Help
```bash
# Generate system diagnostic report
./scripts/token_expiry_monitor.sh diagnostics

# Create support ticket with system info
./scripts/token_expiry_monitor.sh create-support-ticket

# Contact infrastructure team
./scripts/token_expiry_monitor.sh contact-infra "Issue description"
```

---

## Quick Reference

### Essential Commands
```bash
# Interactive monitoring
./scripts/token_expiry_monitor.sh

# Quick status check
./scripts/token_expiry_monitor.sh monitor-all

# Generate report
./scripts/token_expiry_monitor.sh report

# Start automated monitoring
./scripts/token_expiry_scheduler.sh start

# Python integration
python3 scripts/token_expiry_integrator.py monitor
```

### Key Files & Locations
- **Scripts**: `scripts/token_expiry_*.sh`, `scripts/token_expiry_integrator.py`
- **Configuration**: `~/.token_scheduler.conf`
- **Reports**: `reports/token_expiry_report_*.md`
- **Notifications**: `notifications/token_expiry_alert_*.md`
- **Logs**: `logs/token_*.log`

### VS Code Tasks
- **Token Expiry: Monitor All** - Complete ecosystem monitoring
- **Token Expiry: Generate Report** - Create comprehensive report
- **Token Expiry: Interactive Monitor** - Launch interactive dashboard
- **Token Expiry: Start Scheduler** - Begin automated monitoring

---

## Version Information

**Version:** 1.0.0  
**Security Level:** Tier 3 - Infrastructure Monitoring  
**Integration:** DevOnboarder Token Architecture v2.1  
**Supported Environments:** Ubuntu 24.04 LTS, Python 3.8+  
**Last Updated:** October 12, 2025  
**Documentation Author:** GitHub Copilot (Enhanced by DevOnboarder Team)

---

*This documentation is automatically maintained and updated with system changes. For the latest version, refer to the repository.*