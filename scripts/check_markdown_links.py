#!/usr/bin/env python3
"""Fail when a relative Markdown link points to a missing repository path."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[1]
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")


def destination(raw: str) -> str:
    value = raw.strip()
    if value.startswith("<") and value.endswith(">"):
        value = value[1:-1]
    if " " in value and not value.startswith(("http://", "https://")):
        value = value.split(" ", 1)[0]
    return unquote(value.split("#", 1)[0])


failures: list[str] = []

for markdown in sorted(ROOT.rglob("*.md")):
    if ".git" in markdown.parts:
        continue
    content = markdown.read_text(encoding="utf-8")
    for line_number, line in enumerate(content.splitlines(), 1):
        for match in LINK.finditer(line):
            target = destination(match.group(1))
            if not target or target.startswith(("http://", "https://", "mailto:")):
                continue
            resolved = (markdown.parent / target).resolve()
            try:
                resolved.relative_to(ROOT)
            except ValueError:
                failures.append(f"{markdown.relative_to(ROOT)}:{line_number}: escapes repository: {target}")
                continue
            if not resolved.exists():
                failures.append(f"{markdown.relative_to(ROOT)}:{line_number}: missing: {target}")

if failures:
    print("Broken local Markdown links:", file=sys.stderr)
    print("\n".join(failures), file=sys.stderr)
    raise SystemExit(1)

print("OK: local Markdown links resolve")
