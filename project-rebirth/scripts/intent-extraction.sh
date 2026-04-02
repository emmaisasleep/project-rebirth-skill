#!/bin/bash
set -euo pipefail

echo "=== INTENT EXTRACTION ==="
echo ""

# --- API Routes & Endpoints ---
echo "--- API ROUTES & ENDPOINTS ---"
# Express / Koa / Fastify (Node.js)
rg -n "router\.(get|post|put|delete|patch|use)\b|app\.(get|post|put|delete|patch)\(" \
  --type-add 'node:*.{ts,js,tsx,jsx,mjs,cjs}' -tnode 2>/dev/null | head -60 || true

# Flask / FastAPI / Django (Python)
rg -n "@(app|bp|router)\.(get|post|put|delete|patch|route)\b|@router\.(get|post|put|delete|patch)\b|path\(|re_path\(|url\(" \
  --type py 2>/dev/null | head -60 || true

# Spring Boot (Java/Kotlin)
rg -n "@(GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping|RequestMapping)\b" \
  --type-add 'jvm:*.{java,kt}' -tjvm 2>/dev/null | head -60 || true

# Gin / Chi / Echo (Go)
rg -n "\.(GET|POST|PUT|DELETE|PATCH|Handle)\(" \
  --type go 2>/dev/null | head -40 || true

# Laravel (PHP)
rg -n "Route::(get|post|put|delete|patch|any|resource)\(" \
  --type php 2>/dev/null | head -40 || true

# gRPC / protobuf service definitions
rg -n "^(rpc |service )" \
  --type-add 'proto:*.proto' -tproto 2>/dev/null | head -40 || true
echo ""

# --- Data Models & Schemas ---
echo "--- DATA MODELS & SCHEMAS ---"
# TypeScript/JavaScript: interfaces, type aliases, Zod/Yup schemas
rg -n "^(export )?(interface|type|class)\s+\w+(Model|Schema|Entity|DTO|Record|Payload)?\b|\.schema\(|z\.object\(" \
  --type-add 'node:*.{ts,tsx}' -tnode 2>/dev/null | head -60 || true

# Python: dataclasses, Pydantic, Django models, SQLAlchemy
rg -n "class \w+\((models\.Model|BaseModel|Schema|Base)\)|@dataclass" \
  --type py 2>/dev/null | head -60 || true

# Java/Kotlin: JPA entities, data classes
rg -n "@(Entity|Table|Document|Schema)\b|^data class " \
  --type-add 'jvm:*.{java,kt}' -tjvm 2>/dev/null | head -60 || true

# Go: struct definitions with json/db tags
rg -n "^type \w+ struct" --type go 2>/dev/null | head -40 || true

# Prisma schema
rg -n "^model \w+ \{" \
  --type-add 'prisma:*.prisma' -tprisma 2>/dev/null | head -40 || true

# Database migrations / SQL
rg -n "^(CREATE TABLE|ALTER TABLE|CREATE INDEX)" \
  --type-add 'sql:*.{sql,migration}' -tsql 2>/dev/null | head -40 || true
echo ""

# --- Test Descriptions (reveal expected behavior) ---
echo "--- TEST DESCRIPTIONS ---"
rg -n "(describe|it|test|context|specify)\s*\(" \
  --type-add 'test:*.{test.ts,test.js,spec.ts,spec.js,test.tsx,spec.tsx}' -ttest 2>/dev/null | head -80 \
  || rg -n "(describe|it|test|context)\s*\(" -g "*.test.*" -g "*.spec.*" 2>/dev/null | head -80 \
  || true

# Python pytest / unittest
rg -n "def test_\w+|class Test\w+" --type py 2>/dev/null | head -60 || true

# Java/Kotlin: JUnit
rg -n "@Test\b|fun test\w+\(" --type-add 'jvm:*.{java,kt}' -tjvm 2>/dev/null | head -60 || true
echo ""

# --- Environment Variables & Config (reveals integrations) ---
echo "--- ENVIRONMENT VARIABLES & CONFIG ---"
echo "# Environment variable references:"
rg -n "process\.env\.\w+|os\.environ\[|os\.getenv\(|env\(\"|config\.\w+\b" \
  2>/dev/null | head -50 || true

echo ""
echo "# .env file (first 30 non-secret lines):"
if [ -f .env.example ] || [ -f .env.sample ] || [ -f .env.template ]; then
  cat .env.example 2>/dev/null || cat .env.sample 2>/dev/null || cat .env.template 2>/dev/null | head -30
elif [ -f .env ]; then
  # Strip lines that look like secrets (values with = and non-empty right side)
  grep -E "^[A-Z_]+=($|#|\"\")" .env | head -30 2>/dev/null || \
    echo "(skipped .env — contains secret values; review manually)"
fi

echo ""
echo "# Config YAML/TOML files:"
find . -maxdepth 3 -name "*.yaml" -o -name "*.yml" -o -name "*.toml" \
  | grep -v 'node_modules\|\.git\|dist\|build\|target\|venv' \
  | grep -iE "(config|settings|application)\." \
  | head -10 \
  | while read -r f; do
      echo "--- $f ---"
      cat "$f" | head -40
    done 2>/dev/null || true
echo ""

echo "=== END INTENT EXTRACTION ==="
