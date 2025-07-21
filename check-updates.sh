#!/bin/bash

# Simple update checker - can be run periodically or on startup

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/accionlabs/hugo-quarto-docs.git"

# Check if git is available
if ! command -v git &> /dev/null; then
    exit 0
fi

# Get current commit if in git repo
current_commit=""
if [ -d ".git" ]; then
    current_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
fi

# Check latest commit (quietly)
latest_commit=$(git ls-remote "$REPO_URL" HEAD 2>/dev/null | cut -f1)

if [ "$current_commit" != "$latest_commit" ] && [ -n "$latest_commit" ]; then
    echo -e "${YELLOW}📢 Documentation System Update Available!${NC}"
    echo -e "${BLUE}   Run './update.sh' to get the latest features and improvements${NC}"
    echo -e "${GREEN}   Your content will be safely preserved during the update${NC}"
    echo
fi