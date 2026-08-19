#!/bin/bash

echo "=== Security Validation for BuzzAILab ==="

# Check for sensitive files
echo "Checking for sensitive files..."
if find . -type f \( -name "*.key" -o -name "*.pem" -o -name "*.cert" -o -name "secrets*" \) 2>/dev/null | grep -q .; then
    echo "ERROR: Sensitive files found in repository"
    find . -type f \( -name "*.key" -o -name "*.pem" -o -name "*.cert" -o -name "secrets*" \)
    exit 1
else
    echo "OK: No sensitive files found"
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

echo "Security validation completed successfully"