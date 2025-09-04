# Production Deployment Example

## Before (Traditional .env approach)

```bash
# Manual setup required
export AAR_TOKEN=your_production_token
export DISCORD_BOT_TOKEN=your_discord_token
# ... all other tokens manually set
```

## After (Token Auto-Creation)

```bash
# If .tokens.prod doesn't exist, it's auto-created with template
# If .tokens.prod DOES exist, it's used directly - zero change needed

# System automatically loads appropriate file:
APP_ENV=production python scripts/token_loader.py load
# Uses existing production tokens seamlessly
```

## Migration Path (One-Time Only)

```bash
# Move existing tokens to new system (optional)
echo "AAR_TOKEN=your_existing_production_token" > .tokens.prod
echo "DISCORD_BOT_TOKEN=your_existing_discord_token" >> .tokens.prod
# ... etc for all tokens you already have

# System now uses organized token file instead of scattered env vars
```
