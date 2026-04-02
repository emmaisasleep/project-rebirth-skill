#!/bin/bash

# Directory structure (2 levels, ignore noise)

find . -maxdepth 3 -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/venv/*' \
  | head -200

# Package manifests — what's declared vs what's actually used
cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null || cat Cargo.toml 2>/dev/null || cat go.mod 2>/dev/null

# README — the original intent document
cat README.md 2>/dev/null || cat README.rst 2>/dev/null