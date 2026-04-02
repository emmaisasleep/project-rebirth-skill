#!/bin/bash
set -euo pipefail

echo "=== DATA FLOW MAPPING ==="
echo "Traces what enters, transforms, and leaves the system."
echo ""

# --- INPUTS ---
echo "--- INPUTS (what data enters the system) ---"

echo "# HTTP request handlers (body/query/param parsing):"
rg -n "req\.(body|params|query|files)\b|request\.(json|form|args|files)\(\)|@RequestBody|@PathVariable|@RequestParam|c\.(Param|Query|Body|ShouldBind)\(" \
  --type-add 'web:*.{ts,js,tsx,jsx,py,java,kt,go}' -tweb 2>/dev/null | head -50 || true

echo ""
echo "# File upload patterns:"
rg -n "multer|busboy|formidable|UploadFile|MultipartFile|multipart\.form-data|mime\.(type|content)|files\[" \
  --type-add 'web:*.{ts,js,tsx,jsx,py,java,kt,go}' -tweb 2>/dev/null | head -30 || true

echo ""
echo "# CLI argument parsing:"
rg -n "process\.argv|argparse\|click\.|cobra\.|cli\.App\|flag\.(String|Int|Bool)\|commander\." \
  --type-add 'code:*.{ts,js,py,go}' -tcode 2>/dev/null | head -30 || true

echo ""
echo "# Message queue / event consumers:"
rg -n "\.subscribe\(|\.consume\(|\.on\(['\"]message|channel\.assertQueue\|@SqsListener\|@KafkaListener\|pubsub\." \
  --type-add 'code:*.{ts,js,tsx,jsx,py,java,kt,go}' -tcode 2>/dev/null | head -30 || true

echo ""
echo "# Cron / scheduled job definitions:"
rg -n "cron\.|@Scheduled\|schedule\.|setInterval\|node-cron\|celery\|beat\|@Cron" \
  --type-add 'code:*.{ts,js,py,java,kt}' -tcode 2>/dev/null | head -20 || true
echo ""

# --- TRANSFORMATIONS (business logic) ---
echo "--- TRANSFORMATIONS (core business logic signals) ---"

echo "# Service / use-case / domain layer files:"
find . -type f \( \
  -name '*service*' -o -name '*Service*' \
  -o -name '*handler*' -o -name '*Handler*' \
  -o -name '*usecase*' -o -name '*UseCase*' \
  -o -name '*domain*' -o -name '*Domain*' \
  -o -name '*business*' \
  \) \
  -not -path '*/node_modules/*' -not -path '*/.git/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | head -30 || echo "(none found)"

echo ""
echo "# Validation logic:"
rg -n "validate\b|\.isValid\b|Joi\.\|yup\.\|zod\.\|@Valid\b|@Validated\b|validator\." \
  --type-add 'code:*.{ts,js,tsx,jsx,py,java,kt,go}' -tcode 2>/dev/null | head -40 || true

echo ""
echo "# Computation / calculation patterns:"
rg -n "function (calculate|compute|process|transform|aggregate|enrich)\w*\b" \
  --type-add 'code:*.{ts,js,tsx,jsx,py,go}' -tcode 2>/dev/null | head -30 || true
echo ""

# --- OUTPUTS ---
echo "--- OUTPUTS (what leaves the system) ---"

echo "# API response senders:"
rg -n "res\.(json|send|status)\(|response\.(json|ok)\(\)|return (Response|JSONResponse|Ok)\(|c\.(JSON|String|File)\(" \
  --type-add 'web:*.{ts,js,tsx,jsx,py,java,kt,go}' -tweb 2>/dev/null | head -50 || true

echo ""
echo "# Database writes (mutations):"
rg -n "\.save\(\|\.create\(\|\.update\(\|\.insert\(\|\.upsert\(\|\.delete\(\|\.destroy\(\|session\.add\(\|em\.persist\(" \
  --type-add 'code:*.{ts,js,tsx,jsx,py,java,kt,go}' -tcode 2>/dev/null | head -40 || true

echo ""
echo "# File writes:"
rg -n "fs\.write\|open\(.*['\"]w\|writeFile\|FileOutputStream\|os\.path\.join\|pathlib\." \
  --type-add 'code:*.{ts,js,py,java,go}' -tcode 2>/dev/null | head -30 || true

echo ""
echo "# Rendered output (SSR, PDF, reports):"
rg -n "\.render\(|renderToString\|pdfkit\|puppeteer\|weasyprint\|PDFDocument\|template\.execute\(" \
  --type-add 'code:*.{ts,js,tsx,jsx,py,go}' -tcode 2>/dev/null | head -20 || true
echo ""

# --- SIDE EFFECTS ---
echo "--- SIDE EFFECTS (external calls, notifications, async) ---"

echo "# Outbound HTTP calls:"
rg -n "axios\.\|fetch\(\|requests\.(get|post|put|delete)\(|http\.Get\(|RestTemplate\.\|httpClient\." \
  --type-add 'code:*.{ts,js,tsx,jsx,py,java,kt,go}' -tcode 2>/dev/null | head -40 || true

echo ""
echo "# Email / notification sending:"
rg -n "sendEmail\|\.send\(.*mail\|nodemailer\|sendgrid\|mailgun\|ses\.(send\|sendEmail)\|smtplib\|notify\(" \
  --type-add 'code:*.{ts,js,py,java,go}' -tcode 2>/dev/null | head -30 || true

echo ""
echo "# Webhook dispatchers / event publishing:"
rg -n "\.emit\(\|EventBus\.\|publisher\.\|dispatchEvent\|\.publish\(\|webhook\." \
  --type-add 'code:*.{ts,js,tsx,jsx,py,java,kt,go}' -tcode 2>/dev/null | head -30 || true

echo ""
echo "# Async job / queue enqueue:"
rg -n "\.add\(\|\.enqueue\(\|delay\.|Queue\.(add\|push)\|task\.apply_async\|background_task\." \
  --type-add 'code:*.{ts,js,py,java,go}' -tcode 2>/dev/null | head -30 || true

echo ""
echo "# Audit / structured logging (business-level events):"
rg -n "audit(Log\|Trail\|Event)\|logger\.(info\|warn\|error)\(.*event\|structlog\.\|log\.With\(" \
  --type-add 'code:*.{ts,js,py,java,kt,go}' -tcode 2>/dev/null | head -30 || true
echo ""

echo "=== END DATA FLOW MAPPING ==="
echo ""
echo "Synthesize the above into Phase 2.4 narrative:"
echo "  - INPUTS  → How data enters (HTTP, files, CLI, events, schedule)"
echo "  - TRANSFORMATIONS → What business logic is applied"
echo "  - OUTPUTS → What is returned or persisted"
echo "  - SIDE EFFECTS → External calls, notifications, async work"
