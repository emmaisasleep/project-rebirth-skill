#!/bin/bash
set -euo pipefail

echo "=== FRICTION MAPPING ==="
echo ""

# --- Technical Debt Markers ---
echo "--- TECHNICAL DEBT MARKERS ---"
echo "# Summary counts:"
rg -n "TODO|FIXME|HACK|WORKAROUND|XXX|TEMP|DEPRECATED" --stats-only 2>/dev/null || \
  echo "(no debt markers found or rg unavailable)"

echo ""
echo "# Top 50 debt markers with context:"
rg -n "TODO|FIXME|HACK|WORKAROUND|XXX|TEMP|DEPRECATED" 2>/dev/null | head -50 || true
echo ""

# --- File Complexity (by line count) ---
echo "--- FILE COMPLEXITY (longest source files) ---"
echo "# Source files by line count:"
find . -type f \( \
  -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \
  -o -name '*.py' -o -name '*.java' -o -name '*.kt' -o -name '*.go' \
  -o -name '*.rs' -o -name '*.rb' -o -name '*.php' \
  \) \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/target/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/venv/*' \
  -not -path '*/vendor/*' \
  | xargs wc -l 2>/dev/null \
  | sort -rn \
  | head -25 \
  || echo "(no source files found)"
echo ""

# --- Dependency Bloat ---
echo "--- DEPENDENCY BLOAT ---"

# Node.js
if [ -f package.json ]; then
  echo "# Node.js (package.json):"
  python3 -c "
import json, sys
try:
  with open('package.json') as f:
    d = json.load(f)
  deps = {**d.get('dependencies', {}), **d.get('devDependencies', {})}
  print(f'Total declared deps: {len(deps)}')
  print(f'  Runtime: {len(d.get(\"dependencies\", {}))}')
  print(f'  Dev:     {len(d.get(\"devDependencies\", {}))}')
  print()
  for k, v in sorted(deps.items()):
    print(f'  {k}: {v}')
except Exception as e:
  print(f'Error parsing package.json: {e}')
" 2>/dev/null || true
fi

# Python (pyproject.toml or requirements.txt)
if [ -f pyproject.toml ]; then
  echo "# Python (pyproject.toml):"
  python3 -c "
try:
  import tomllib
except ImportError:
  try:
    import tomli as tomllib
  except ImportError:
    print('(tomllib not available — install Python 3.11+ or tomli)')
    exit(0)
with open('pyproject.toml', 'rb') as f:
  d = tomllib.load(f)
deps = d.get('project', {}).get('dependencies', [])
dev_deps = d.get('project', {}).get('optional-dependencies', {})
print(f'Runtime deps: {len(deps)}')
for dep in deps: print(f'  {dep}')
for group, pkgs in dev_deps.items():
  print(f'Dev ({group}): {len(pkgs)}')
  for p in pkgs: print(f'  {p}')
" 2>/dev/null || cat pyproject.toml | grep -A 50 "\[project.dependencies\]" | head -30 || true
elif [ -f requirements.txt ]; then
  echo "# Python (requirements.txt):"
  echo "Total: $(grep -v '^\s*#' requirements.txt | grep -v '^\s*$' | wc -l) packages"
  cat requirements.txt
fi

# Go
if [ -f go.mod ]; then
  echo "# Go (go.mod):"
  echo "Total requires: $(grep -c '^\s*require\|^\t' go.mod 2>/dev/null || echo 0)"
  cat go.mod
fi

# Java (pom.xml)
if [ -f pom.xml ]; then
  echo "# Java (pom.xml):"
  DEP_COUNT=$(grep -c '<dependency>' pom.xml 2>/dev/null || echo 0)
  echo "Total <dependency> declarations: $DEP_COUNT"
fi
echo ""

# --- Tangled Import Heuristic (files with most inbound imports) ---
echo "--- MOST-IMPORTED FILES (coupling hotspots) ---"
echo "# Files referenced most often by other files (likely over-coupled):"
rg -oh "from ['\"]([^'\"]+)['\"]|require\(['\"]([^'\"]+)['\"]" \
  --type-add 'code:*.{ts,js,tsx,jsx,py}' -tcode 2>/dev/null \
  | grep -oE "['\"][^'\"]+['\"]" \
  | tr -d "'\""  \
  | sort | uniq -c | sort -rn | head -20 \
  || true
echo ""

# --- Circular Import Detection Heuristic ---
echo "--- CIRCULAR IMPORT HEURISTIC ---"
echo "# Checking for mutually-importing file pairs (A imports B and B imports A):"
echo "# (Showing top candidates — verify with a proper tool like madge or pylint)"

TMPFILE=$(mktemp)
# Collect all import-from pairs: "importer -> importee"
rg -o "from ['\"](\./[^'\"]+)['\"]" --replace '$1' \
  --type-add 'code:*.{ts,js,tsx,jsx}' -tcode -l 2>/dev/null \
  | head -200 > "$TMPFILE" || true

rg -o "from ['\"](\./[^'\"]+)['\"]" --replace '$1' \
  --type-add 'code:*.{ts,js,tsx,jsx}' -tcode 2>/dev/null \
  | awk -F: '{gsub(/^\.\//, "", $2); print $1 " -> " $2}' \
  | sort > "${TMPFILE}.pairs" 2>/dev/null || true

if [ -s "${TMPFILE}.pairs" ]; then
  # Find pairs where both directions appear
  while IFS=' -> ' read -r a b; do
    if grep -qF "$b -> $a" "${TMPFILE}.pairs" 2>/dev/null; then
      echo "  MUTUAL: $a <-> $b"
    fi
  done < "${TMPFILE}.pairs" | sort -u | head -20 || true
else
  echo "  (no relative imports found — check for absolute imports manually)"
fi

rm -f "$TMPFILE" "${TMPFILE}.pairs"
echo ""

# --- Test Coverage Heuristic ---
echo "--- TEST COVERAGE HEURISTIC ---"
SOURCE_FILES=$(find . -type f \( \
  -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.java' -o -name '*.go' \
  \) \
  -not -name '*.test.*' -not -name '*.spec.*' -not -name '*_test.*' \
  -not -path '*/node_modules/*' -not -path '*/.git/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/__pycache__/*' -not -path '*/venv/*' \
  2>/dev/null | wc -l)

TEST_FILES=$(find . -type f \( \
  -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.*' -o -name '*_test.go' \
  \) \
  -not -path '*/node_modules/*' -not -path '*/.git/*' \
  2>/dev/null | wc -l)

echo "Source files: $SOURCE_FILES"
echo "Test files:   $TEST_FILES"
if [ "$SOURCE_FILES" -gt 0 ]; then
  RATIO=$(python3 -c "print(f'{($TEST_FILES / $SOURCE_FILES) * 100:.0f}%')" 2>/dev/null || echo "?")
  echo "Test/source ratio: $RATIO"
  if [ "$TEST_FILES" -eq 0 ]; then
    echo "[WARNING] No test files detected. Requirements must be derived from API boundaries and data models."
  fi
fi
echo ""

echo "=== END FRICTION MAPPING ==="
