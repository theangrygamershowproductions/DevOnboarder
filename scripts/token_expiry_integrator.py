#!/usr/bin/env python3
"""
token_expiry_integrator.py - Integration layer between token expiry monitoring and DevOnboarder token system

This module provides advanced token expiry tracking capabilities that integrate with
DevOnboarder's existing token_loader.py system, providing automated expiry detection,
notification scheduling, and rotation planning.

Version: 1.0.0
Security Level: Tier 3 - Infrastructure Monitoring
"""

import os
import sys
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple, Any
from pathlib import Path
import subprocess

# Add project root to path for imports
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

try:
    from token_loader import TokenLoader
except ImportError:
    print("ERROR: Cannot import token_loader.py - ensure it's in the scripts directory")
    sys.exit(1)

# Configuration
LOG_DIR = PROJECT_ROOT / "logs"
REPORT_DIR = PROJECT_ROOT / "reports"
NOTIFICATION_DIR = PROJECT_ROOT / "notifications"
CONFIG_DIR = Path.home() / ".config" / "devonboarder"

# Ensure directories exist
for directory in [LOG_DIR, REPORT_DIR, NOTIFICATION_DIR, CONFIG_DIR]:
    directory.mkdir(parents=True, exist_ok=True)

# Logging setup
logging.basicConfig(
    filename=LOG_DIR / "token_expiry_integrator.log",
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class TokenExpiryIntegrator:
    """
    Integrates token expiry monitoring with DevOnboarder's token system.

    Provides advanced expiry tracking, automated notifications, and rotation planning
    that leverages the existing token_loader.py infrastructure.
    """

    # Token categories from DevOnboarder architecture
    CICD_TOKENS = [
        "AAR_TOKEN",
        "CI_BOT_TOKEN",
        "CI_ISSUE_AUTOMATION_TOKEN",
        "DEV_ORCHESTRATION_BOT_KEY",
        "PROD_ORCHESTRATION_BOT_KEY",
        "STAGING_ORCHESTRATION_BOT_KEY"
    ]

    RUNTIME_TOKENS = [
        "DISCORD_BOT_TOKEN",
        "DISCORD_CLIENT_SECRET",
        "BOT_JWT",
        "CF_DNS_API_TOKEN",
        "TUNNEL_TOKEN"
    ]

    MAINTAINER_TOKENS = [
        "EXTERNAL_PR_MAINTAINER_TOKEN",
        "SECURITY_AUDIT_TOKEN",
        "EMERGENCY_OVERRIDE_TOKEN"
    ]

    # Expiry thresholds (days)
    THRESHOLDS = {
        'critical': 7,   # Immediate action required
        'warning': 30,   # Plan rotation
        'info': 45,      # Monitor closely
        'target': 90     # Current target expiry
    }

    def __init__(self):
        """Initialize the token expiry integrator."""
        self.token_loader = TokenLoader()
        self.maintainer_store = CONFIG_DIR / "maintainer_tokens"
        self.maintainer_store.mkdir(exist_ok=True)

        logger.info("Token Expiry Integrator initialized")

    def get_token_expiry_info(self, token_name: str, token_type: str) -> Dict[str, Any]:
        """
        Get comprehensive expiry information for a token.

        Args:
            token_name: Name of the token to check
            token_type: Type of token ('cicd', 'runtime', 'maintainer')

        Returns:
            Dictionary containing expiry information
        """
        try:
            result = {
                'token_name': token_name,
                'token_type': token_type,
                'status': 'unknown',
                'days_until_expiry': None,
                'expiry_date': None,
                'analysis': 'UNKNOWN',
                'action_required': 'Investigate',
                'last_checked': datetime.utcnow().isoformat()
            }

            if token_type == 'maintainer':
                # Check maintainer token expiry from metadata
                expiry_info = self._check_maintainer_token_expiry(token_name)
                result.update(expiry_info)
            elif token_type == 'cicd':
                # Check CI/CD token (approximate based on policy)
                expiry_info = self._check_cicd_token_expiry(token_name)
                result.update(expiry_info)
            elif token_type == 'runtime':
                # Check runtime token (typically no expiry)
                expiry_info = self._check_runtime_token_expiry(token_name)
                result.update(expiry_info)
            else:
                result['status'] = 'invalid_type'
                result['analysis'] = 'INVALID_TOKEN_TYPE'

            # Analyze the status
            result['analysis'] = self._analyze_token_status(result)

            return result

        except Exception as e:
            logger.error(f"Error checking token {token_name}: {e}")
            return {
                'token_name': token_name,
                'token_type': token_type,
                'status': 'error',
                'error': str(e),
                'analysis': 'ERROR_CHECKING_TOKEN',
                'last_checked': datetime.utcnow().isoformat()
            }

    def _check_maintainer_token_expiry(self, token_name: str) -> Dict[str, Any]:
        """Check expiry for maintainer tokens with detailed metadata."""
        meta_file = self.maintainer_store / f"{token_name}.meta"

        if not meta_file.exists():
            return {
                'status': 'not_found',
                'analysis': 'TOKEN_NOT_FOUND'
            }

        try:
            with open(meta_file, 'r') as f:
                metadata = {}
                for line in f:
                    if ':' in line:
                        key, value = line.split(':', 1)
                        metadata[key.strip()] = value.strip()

            expiry_date_str = metadata.get('expires')
            if not expiry_date_str:
                return {
                    'status': 'no_expiry_info',
                    'analysis': 'NO_EXPIRY_INFO'
                }

            # Parse expiry date
            expiry_date = datetime.fromisoformat(expiry_date_str.replace('Z', '+00:00'))
            now = datetime.utcnow().replace(tzinfo=expiry_date.tzinfo)

            days_until_expiry = (expiry_date - now).days

            if days_until_expiry < 0:
                status = 'expired'
            elif days_until_expiry <= self.THRESHOLDS['critical']:
                status = 'critical'
            elif days_until_expiry <= self.THRESHOLDS['warning']:
                status = 'warning'
            elif days_until_expiry <= self.THRESHOLDS['info']:
                status = 'info'
            else:
                status = 'healthy'

            return {
                'status': status,
                'days_until_expiry': max(0, days_until_expiry),
                'expiry_date': expiry_date_str,
                'created': metadata.get('created'),
                'last_rotated': metadata.get('last_rotated'),
                'rotation_count': metadata.get('rotation_count', '0')
            }

        except Exception as e:
            logger.error(f"Error reading maintainer token metadata for {token_name}: {e}")
            return {
                'status': 'metadata_error',
                'error': str(e)
            }

    def _check_cicd_token_expiry(self, token_name: str) -> Dict[str, Any]:
        """Check expiry for CI/CD tokens based on DevOnboarder policy."""
        try:
            # Load tokens and check if the token exists
            tokens = self.token_loader.load_tokens()
            token_value = tokens.get(token_name)

            if token_value is None:
                return {
                    'status': 'not_found',
                    'analysis': 'TOKEN_NOT_FOUND'
                }

            # Check if it's a placeholder
            if token_value and (token_value.startswith('CHANGE_ME') or token_value.startswith('ci_test_')):
                return {
                    'status': 'placeholder',
                    'analysis': 'PLACEHOLDER_TOKEN'
                }

            # CI/CD tokens follow 90-day policy
            # We don't have exact expiry dates, so we use policy-based approximation
            return {
                'status': 'policy_based',
                'days_until_expiry': self.THRESHOLDS['target'],  # 90 days
                'expiry_policy': '90_days',
                'analysis': 'APPROXIMATE_90_DAYS'
            }

        except Exception as e:
            logger.error(f"Error checking CI/CD token {token_name}: {e}")
            return {
                'status': 'error',
                'error': str(e)
            }

    def _check_runtime_token_expiry(self, token_name: str) -> Dict[str, Any]:
        """Check expiry for runtime tokens (typically no expiry)."""
        try:
            # Load runtime tokens
            runtime_tokens = self.token_loader.load_tokens_by_type(self.token_loader.TOKEN_TYPE_RUNTIME)
            token_value = runtime_tokens.get(token_name)

            if token_value is None:
                return {
                    'status': 'not_found',
                    'analysis': 'TOKEN_NOT_FOUND'
                }

            if token_value and token_value.startswith('CHANGE_ME'):
                return {
                    'status': 'placeholder',
                    'analysis': 'PLACEHOLDER_TOKEN'
                }

            # Runtime tokens typically don't expire
            return {
                'status': 'no_expiry',
                'analysis': 'RUNTIME_NO_EXPIRY'
            }

        except Exception as e:
            logger.error(f"Error checking runtime token {token_name}: {e}")
            return {
                'status': 'error',
                'error': str(e)
            }

    def _analyze_token_status(self, token_info: Dict[str, Any]) -> str:
        """Analyze token status and provide action recommendations."""
        status = token_info.get('status', 'unknown')
        days = token_info.get('days_until_expiry')

        if status == 'expired':
            return 'EXPIRED'
        elif status == 'critical':
            return f'CRITICAL:{days}'
        elif status == 'warning':
            return f'WARNING:{days}'
        elif status == 'info':
            return f'INFO:{days}'
        elif status == 'healthy':
            return f'HEALTHY:{days}'
        elif status == 'policy_based':
            days = token_info.get('days_until_expiry', self.THRESHOLDS['target'])
            if days <= self.THRESHOLDS['critical']:
                return f'CRITICAL:{days}'
            elif days <= self.THRESHOLDS['warning']:
                return f'WARNING:{days}'
            elif days <= self.THRESHOLDS['info']:
                return f'INFO:{days}'
            else:
                return f'HEALTHY:{days}'
        elif status == 'placeholder':
            return 'PLACEHOLDER'
        elif status == 'no_expiry':
            return 'RUNTIME_NO_EXPIRY'
        elif status == 'not_found':
            return 'NOT_FOUND'
        elif status == 'no_expiry_info':
            return 'NO_EXPIRY_INFO'
        else:
            return f'UNKNOWN:{status}'

    def generate_expiry_report(self, include_all: bool = True) -> str:
        """
        Generate a comprehensive token expiry report.

        Args:
            include_all: Whether to include healthy tokens in the report

        Returns:
            Path to the generated report file
        """
        report_data = {
            'generated_at': datetime.utcnow().isoformat(),
            'thresholds': self.THRESHOLDS,
            'tokens': {},
            'summary': {
                'total_tokens': 0,
                'expired': 0,
                'critical': 0,
                'warning': 0,
                'info': 0,
                'healthy': 0,
                'placeholders': 0,
                'not_found': 0
            }
        }

        # Check all token categories
        all_tokens = []
        all_tokens.extend([(t, 'cicd') for t in self.CICD_TOKENS])
        all_tokens.extend([(t, 'runtime') for t in self.RUNTIME_TOKENS])
        all_tokens.extend([(t, 'maintainer') for t in self.MAINTAINER_TOKENS])

        for token_name, token_type in all_tokens:
            expiry_info = self.get_token_expiry_info(token_name, token_type)
            report_data['tokens'][f"{token_type}:{token_name}"] = expiry_info
            report_data['summary']['total_tokens'] += 1

            # Update summary counts
            analysis = expiry_info.get('analysis', '')
            if 'EXPIRED' in analysis:
                report_data['summary']['expired'] += 1
            elif 'CRITICAL:' in analysis:
                report_data['summary']['critical'] += 1
            elif 'WARNING:' in analysis:
                report_data['summary']['warning'] += 1
            elif 'INFO:' in analysis:
                report_data['summary']['info'] += 1
            elif 'HEALTHY:' in analysis:
                report_data['summary']['healthy'] += 1
            elif 'PLACEHOLDER' in analysis:
                report_data['summary']['placeholders'] += 1
            elif 'NOT_FOUND' in analysis:
                report_data['summary']['not_found'] += 1

        # Generate markdown report
        report_file = REPORT_DIR / f"token_expiry_integrator_report_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.md"

        with open(report_file, 'w') as f:
            f.write("# Token Expiry Integration Report\n\n")
            f.write(f"**Generated:** {report_data['generated_at']}\n\n")

            # Summary section
            f.write("## Executive Summary\n\n")
            summary = report_data['summary']
            f.write(f"- **Total Tokens Monitored:** {summary['total_tokens']}\n")
            f.write(f"- **Expired:** {summary['expired']}\n")
            f.write(f"- **Critical (< 7 days):** {summary['critical']}\n")
            f.write(f"- **Warning (7-30 days):** {summary['warning']}\n")
            f.write(f"- **Info (30-45 days):** {summary['info']}\n")
            f.write(f"- **Healthy (> 45 days):** {summary['healthy']}\n")
            f.write(f"- **Placeholders:** {summary['placeholders']}\n")
            f.write(f"- **Not Found:** {summary['not_found']}\n\n")

            # Thresholds
            f.write("## Monitoring Thresholds\n\n")
            thresholds = report_data['thresholds']
            f.write(f"- **Critical:** < {thresholds['critical']} days\n")
            f.write(f"- **Warning:** {thresholds['critical']}-{thresholds['warning']} days\n")
            f.write(f"- **Info:** {thresholds['warning']}-{thresholds['info']} days\n")
            f.write(f"- **Target Expiry:** {thresholds['target']} days\n\n")

            # Token details
            for category_name, category_tokens in [
                ("CI/CD Tokens", self.CICD_TOKENS),
                ("Runtime Tokens", self.RUNTIME_TOKENS),
                ("Maintainer Tokens", self.MAINTAINER_TOKENS)
            ]:
                f.write(f"## {category_name}\n\n")

                for token_name in category_tokens:
                    token_key = f"{category_name.lower().split()[0]}:{token_name}"
                    if token_key in report_data['tokens']:
                        token_info = report_data['tokens'][token_key]
                        analysis = token_info.get('analysis', 'UNKNOWN')

                        # Determine status emoji and action
                        if 'EXPIRED' in analysis:
                            emoji = "🚨"
                            action = "IMMEDIATE ROTATION REQUIRED"
                        elif 'CRITICAL:' in analysis:
                            emoji = "🔴"
                            action = "URGENT ROTATION REQUIRED"
                        elif 'WARNING:' in analysis:
                            emoji = "🟡"
                            action = "PLAN ROTATION"
                        elif 'INFO:' in analysis:
                            emoji = "🟢"
                            action = "MONITOR CLOSELY"
                        elif 'HEALTHY:' in analysis:
                            emoji = "✅"
                            action = "HEALTHY" if include_all else ""
                        elif 'PLACEHOLDER' in analysis:
                            emoji = "🟡"
                            action = "REPLACE PLACEHOLDER"
                        else:
                            emoji = "❓"
                            action = "INVESTIGATE"

                        if include_all or action:
                            f.write(f"### {token_name}\n")
                            f.write(f"- **Status:** {emoji} {analysis}\n")
                            if action:
                                f.write(f"- **Action:** {action}\n")

                            days = token_info.get('days_until_expiry')
                            if days is not None:
                                f.write(f"- **Days Until Expiry:** {days}\n")

                            expiry_date = token_info.get('expiry_date')
                            if expiry_date:
                                f.write(f"- **Expiry Date:** {expiry_date}\n")

                            f.write("\n")

            # Recommendations
            f.write("## Recommendations\n\n")

            if summary['expired'] > 0 or summary['critical'] > 0:
                f.write("### Immediate Actions Required\n")
                f.write("- Rotate all expired and critical tokens immediately\n")
                f.write("- Schedule maintenance windows for token rotation\n")
                f.write("- Test all services after rotation\n")
                f.write("- Notify infrastructure team of changes\n\n")

            if summary['warning'] > 0:
                f.write("### Medium Priority Actions\n")
                f.write("- Plan rotation for warning tokens within maintenance windows\n")
                f.write("- Prepare new tokens in advance\n")
                f.write("- Update rotation documentation\n\n")

            f.write("### Process Improvements\n")
            f.write("- Implement automated expiry alerts\n")
            f.write("- Add token health checks to CI/CD pipelines\n")
            f.write("- Create token rotation calendar\n")
            f.write("- Consider moving to 45-day expiry cycles\n\n")

            f.write("## Integration Details\n\n")
            f.write("- **Token Loader:** Integrated with DevOnboarder token_loader.py\n")
            f.write("- **Security:** Maintains token masking and secure storage\n")
            f.write("- **Monitoring:** Automated expiry tracking and notifications\n")
            f.write("- **Reporting:** Comprehensive status reports with action items\n\n")

            f.write("---\n")
            f.write("*Generated by Token Expiry Integrator v1.0.0*\n")

        logger.info(f"Generated expiry report: {report_file}")
        return str(report_file)

    def schedule_notifications(self, token_info: Dict[str, Any]) -> Optional[str]:
        """
        Schedule notifications for token expiry based on status.

        Args:
            token_info: Token expiry information

        Returns:
            Path to notification file if created, None otherwise
        """
        analysis = token_info.get('analysis', '')
        token_name = token_info.get('token_name', 'unknown')

        # Only create notifications for critical issues
        if not ('EXPIRED' in analysis or 'CRITICAL:' in analysis):
            return None

        notification_file = NOTIFICATION_DIR / f"token_expiry_alert_{token_name}_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.md"

        with open(notification_file, 'w') as f:
            f.write("# 🚨 Token Expiry Alert - Infrastructure Team\n\n")
            f.write(f"**Generated:** {datetime.utcnow().isoformat()}\n")
            f.write(f"**Token:** {token_name}\n")
            f.write(f"**Type:** {token_info.get('token_type', 'unknown')}\n")
            f.write(f"**Status:** {analysis}\n\n")

            # Action items based on severity
            if 'EXPIRED' in analysis:
                f.write("## IMMEDIATE ACTION REQUIRED\n\n")
                f.write("1. **Generate new token** in GitHub (Settings > Developer settings > Personal access tokens)\n")
                f.write("2. **Update token** in appropriate configuration file\n")
                f.write("3. **Test token functionality**\n")
                f.write("4. **Update documentation**\n")
                f.write("5. **Notify team** of successful rotation\n\n")

                f.write("### Security Impact\n")
                f.write("- **HIGH**: Token has expired and is non-functional\n")
                f.write("- **Risk**: CI/CD pipelines may fail, external PR operations may be blocked\n\n")
            else:
                days = token_info.get('days_until_expiry', 'unknown')
                f.write("## URGENT ACTION REQUIRED\n\n")
                f.write(f"1. **Schedule token rotation** within {days} days\n")
                f.write("2. **Prepare new token** generation\n")
                f.write("3. **Plan maintenance window**\n")
                f.write("4. **Backup current configurations**\n\n")

                f.write("### Security Impact\n")
                f.write(f"- **MEDIUM**: Token expires in {days} days\n")
                f.write("- **Risk**: Service disruption if rotation is delayed\n\n")

            f.write("## Infrastructure Team Contacts\n\n")
            f.write("- @theangrygamershowproductions/infrastructure\n")
            f.write("- @tags-devsecops\n\n")

            f.write("---\n")
            f.write("*DevOnboarder Token Expiry Integrator v1.0.0*\n")

        logger.warning(f"Critical token expiry notification created for {token_name}: {analysis}")
        return str(notification_file)

    def run_monitoring_cycle(self) -> Dict[str, Any]:
        """
        Run a complete monitoring cycle for all tokens.

        Returns:
            Summary of monitoring results
        """
        logger.info("Starting token expiry monitoring cycle")

        results = {
            'cycle_start': datetime.utcnow().isoformat(),
            'tokens_checked': 0,
            'critical_issues': 0,
            'warnings': 0,
            'notifications_created': 0,
            'errors': 0,
            'report_generated': False
        }

        # Check all tokens
        all_tokens = []
        all_tokens.extend([(t, 'cicd') for t in self.CICD_TOKENS])
        all_tokens.extend([(t, 'runtime') for t in self.RUNTIME_TOKENS])
        all_tokens.extend([(t, 'maintainer') for t in self.MAINTAINER_TOKENS])

        for token_name, token_type in all_tokens:
            try:
                token_info = self.get_token_expiry_info(token_name, token_type)
                results['tokens_checked'] += 1

                analysis = token_info.get('analysis', '')

                if 'EXPIRED' in analysis or 'CRITICAL:' in analysis:
                    results['critical_issues'] += 1
                    notification_file = self.schedule_notifications(token_info)
                    if notification_file:
                        results['notifications_created'] += 1
                elif 'WARNING:' in analysis:
                    results['warnings'] += 1

            except Exception as e:
                logger.error(f"Error monitoring token {token_name}: {e}")
                results['errors'] += 1

        # Generate comprehensive report
        try:
            report_file = self.generate_expiry_report(include_all=False)
            results['report_generated'] = True
            results['report_file'] = report_file
        except Exception as e:
            logger.error(f"Error generating report: {e}")
            results['errors'] += 1

        results['cycle_end'] = datetime.utcnow().isoformat()

        logger.info(f"Monitoring cycle completed: {results}")
        return results


def main():
    """Main entry point for the token expiry integrator."""
    import argparse

    parser = argparse.ArgumentParser(description="Token Expiry Integrator for DevOnboarder")
    parser.add_argument('command', choices=[
        'check', 'monitor', 'report', 'cycle'
    ], help='Command to execute')
    parser.add_argument('--token', help='Token name for check command')
    parser.add_argument('--type', choices=['cicd', 'runtime', 'maintainer'],
                       help='Token type for check command')
    parser.add_argument('--json', action='store_true',
                       help='Output results as JSON')

    args = parser.parse_args()

    integrator = TokenExpiryIntegrator()

    try:
        if args.command == 'check':
            if not args.token or not args.type:
                print("ERROR: --token and --type required for check command")
                return 1

            result = integrator.get_token_expiry_info(args.token, args.type)
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                print(f"Token: {result['token_name']}")
                print(f"Type: {result['token_type']}")
                print(f"Status: {result['status']}")
                print(f"Analysis: {result['analysis']}")
                if result.get('days_until_expiry') is not None:
                    print(f"Days until expiry: {result['days_until_expiry']}")

        elif args.command == 'monitor':
            # Monitor all tokens and show summary
            result = integrator.run_monitoring_cycle()
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                print("Monitoring cycle completed:")
                print(f"- Tokens checked: {result['tokens_checked']}")
                print(f"- Critical issues: {result['critical_issues']}")
                print(f"- Warnings: {result['warnings']}")
                print(f"- Notifications created: {result['notifications_created']}")
                print(f"- Report generated: {result['report_generated']}")

        elif args.command == 'report':
            # Generate and display report path
            report_file = integrator.generate_expiry_report()
            print(f"Report generated: {report_file}")

        elif args.command == 'cycle':
            # Run full monitoring cycle
            result = integrator.run_monitoring_cycle()
            print(f"Monitoring cycle completed. Report: {result.get('report_file', 'N/A')}")

    except Exception as e:
        logger.error(f"Command execution failed: {e}")
        print(f"ERROR: {e}")
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())