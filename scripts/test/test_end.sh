
            # Show current staged files
            printf 'Actually staged files:\n'
            git diff --cached --name-only | sed 's/^/   /'
            printf '\n'

            printf 'This indicates a systemic pre-commit issue, not just whitespace fixes.\n'
            printf 'Recommended actions:\n'
            printf '   1. Check the log output above for specific error patterns\n'
            printf '   2. Run: source .venv/bin/activate && pre-commit run --all-files\n'
            printf '   3. Or run individual hooks: pre-commit run <hook-name> --all-files\n'
            printf '   4. Check DevOnboarder quality gates documentation\n'

            exit $SECOND_EXIT_CODE
        fi
    else
        echo "Pre-commit hooks failed but no files were modified. Check the errors above."
        exit $COMMIT_EXIT_CODE
    fi
fi
