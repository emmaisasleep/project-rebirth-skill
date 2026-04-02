#!/bin/bash
set -euo pipefail

echo "=== STRUCTURAL SURVEY ==="
echo ""

# --- Language Detection ---
echo "--- LANGUAGE DETECTION ---"
echo "File extension distribution:"
find . -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/target/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/venv/*' \
  -not -path '*/.venv/*' \
  -not -path '*/vendor/*' \
  | grep -oE '\.[a-zA-Z0-9]+$' \
  | sort | uniq -c | sort -rn | head -20 \
  || echo "(no files found)"
echo ""

# --- File Tree ---
echo "--- FILE TREE (source files, max depth 3) ---"
FILE_LIST=$(find . -maxdepth 3 -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/target/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/venv/*' \
  -not -path '*/.venv/*' \
  -not -path '*/vendor/*' \
  2>/dev/null)

FILE_COUNT=$(echo "$FILE_LIST" | wc -l)
echo "$FILE_LIST" | head -200

if [ "$FILE_COUNT" -gt 200 ]; then
  echo ""
  echo "[WARNING] File list truncated — found $FILE_COUNT files, showing first 200."
  echo "Consider running with a narrower scope or increasing the limit."
fi
echo ""

# --- Package Manifests ---
echo "--- PACKAGE MANIFESTS ---"
MANIFEST_FOUND=false

for manifest in package.json pyproject.toml requirements.txt Cargo.toml go.mod pom.xml build.gradle Gemfile composer.json; do
  if [ -f "$manifest" ]; then
    echo "Found: $manifest"
    cat "$manifest"
    echo ""
    MANIFEST_FOUND=true
  fi
done

if [ "$MANIFEST_FOUND" = false ]; then
  echo "[WARNING] No package manifest found. Dependency analysis will be limited."
  echo "Looked for: package.json, pyproject.toml, requirements.txt, Cargo.toml, go.mod, pom.xml, build.gradle, Gemfile, composer.json"
fi
echo ""

# --- .gitignore (reveals what the team treated as noise) ---
echo "--- .GITIGNORE ---"
if [ -f .gitignore ]; then
  cat .gitignore
else
  echo "(no .gitignore found)"
fi
echo ""

# --- README ---
echo "--- README ---"
README_FOUND=false
for readme in README.md README.rst README.txt README; do
  if [ -f "$readme" ]; then
    cat "$readme"
    README_FOUND=true
    break
  fi
done

if [ "$README_FOUND" = false ]; then
  echo "[WARNING] No README found. Lean harder on code analysis for intent."
  echo "Check for alternative docs: docs/, ARCHITECTURE.md, CHANGELOG.md"
  for doc in docs/ARCHITECTURE.md docs/architecture.md ARCHITECTURE.md CHANGELOG.md; do
    if [ -f "$doc" ]; then
      echo ""
      echo "Found alternative: $doc"
      cat "$doc"
    fi
  done
fi
echo ""

echo "=== END STRUCTURAL SURVEY ==="
