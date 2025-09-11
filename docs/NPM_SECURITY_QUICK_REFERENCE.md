# NPM Security Quick Reference

## CRITICAL: Root Pollution Prevention

### NEVER RUN FROM ROOT

```bash
npm audit fix       # Creates 500+ package pollution
npm install         # Violates Root Artifact Guard
npm ci              # Creates root node_modules
```

### CORRECT COMMANDS

```bash
# Service-specific fixes
npm audit fix --prefix frontend
npm audit fix --prefix bot

# Documentation tooling
npx markdownlint-cli2 docs/
npx ajv-cli validate schema.json
```

### Emergency Cleanup

```bash
rm -rf node_modules
bash scripts/enforce_output_location.sh
```

## References

- Full documentation: `docs/security/npm-security-standards.md`
- Root Artifact Guard: `scripts/enforce_output_location.sh`
- Terminal Output Policy: Plain ASCII text only in commands
