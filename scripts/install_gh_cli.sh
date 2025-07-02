#!/usr/bin/env bash
# Install the GitHub CLI on Linux, macOS, or Windows
set -euo pipefail

if command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI already installed at $(which gh)"
    gh --version
    exit 0
fi

os="$(uname -s)"
case "$os" in
    Linux*)
        if [ -f /etc/debian_version ]; then
            sudo mkdir -p -m 0755 /etc/apt/keyrings
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
              | sudo dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
              | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
            sudo apt-get update
            sudo apt-get install -y gh
        else
            echo "Unsupported Linux distribution. Install GitHub CLI manually." >&2
            exit 1
        fi
        ;;
    Darwin*)
        brew install gh
        ;;
    MINGW*|MSYS*|CYGWIN*|Windows*)
        choco install gh --no-progress --yes
        ;;
    *)
        echo "Unsupported OS: $os" >&2
        exit 1
        ;;
esac

which gh
gh --version
