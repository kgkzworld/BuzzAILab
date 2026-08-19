#!/bin/bash

set -euo pipefail

echo "=== Security Validation for BuzzAILab ==="

# Check for sensitive files
echo "Checking for sensitive files..."
if find . -type f -not -path "./.git/*" \( -name "*.key" -o -name "*.pem" -o -name "*.cert" -o -name "secrets" -o -name "secrets.*" -o -name "*.ncryptsec" \) 2>/dev/null | grep -q .; then
    echo "ERROR: Sensitive files found in repository"
    find . -type f -not -path "./.git/*" \( -name "*.key" -o -name "*.pem" -o -name "*.cert" -o -name "secrets" -o -name "secrets.*" -o -name "*.ncryptsec" \)
    exit 1
else
    echo "OK: No sensitive files found"
fi

echo "Checking for credential-shaped content..."
if grep -RInE --exclude-dir=.git --exclude=security-check.sh '(nsec1[023456789acdefghjklmnpqrstuvwxyz]{20,}|-----BEGIN ([A-Z ]+ )?PRIVATE KEY-----|github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9]{30,}|AKIA[0-9A-Z]{16})' .; then
    echo "ERROR: Credential-shaped content found"
    exit 1
else
    echo "OK: No credential-shaped content found"
fi

# Check for large files (over 1MB)
echo "Checking for large files..."
# Simple check for any file that's larger than 1MB
large_files=$(find . -type f -size +1M -not -path "./.git/*" 2>/dev/null | head -5)
if [ -n "$large_files" ]; then
    echo "ERROR: Large files detected:"
    echo "$large_files"
    exit 1
else
    echo "OK: No large files found (>1MB)"
fi

echo "Checking JSON syntax..."
python3 -m json.tool agents/08-capability-routing-catalog.json >/dev/null
echo "OK: JSON syntax valid"

echo "Checking local Markdown links..."
python3 scripts/check_markdown_links.py

echo "Checking whitespace errors..."
git diff --check
git diff --cached --check
echo "OK: No whitespace errors"

echo "Security validation completed successfully"
