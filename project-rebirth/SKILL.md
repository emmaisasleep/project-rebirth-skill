---
name: project-rebirth
description: >
  Reverse-engineer an existing codebase into a "Project Rebirth Kit" — a clean-slate architecture package containing a PRD, CLAUDE.md, and standards config — preserving business logic while purging technical debt. Use this skill whenever the user wants to:

  - Rewrite or rebuild a project from scratch
  - Extract requirements from legacy code
  - Create a PRD from an existing repo
  - Do a "clean slate" or "greenfield" rewrite of an existing system
  - Reverse-engineer what a codebase does
  - Generate a CLAUDE.md for a rebuild
  - Audit a repo for technical debt before rewriting
  - Create architectural documentation from source code

  Trigger when the user says things like:

  - "Start over"
  - "Rewrite this"
  - "Extract the requirements"
  - "What does this codebase actually do"
  - "Clean slate"
  - "Rebirth"
  - "Rebuild from scratch"
  - "Make a PRD from this repo"

  Do NOT use for incremental refactoring, bug fixes, or feature additions to existing code.
---

# Project Rebirth

Reverse-engineer an existing codebase to extract **what it does** (business logic, objectives, data flows) while discarding **how it currently does it** (implementation details, framework choices, architectural debt). Output a "Rebirth Kit" that enables a clean-slate rebuild.

## Why this matters

Rewrites fail when teams carry forward the same architectural assumptions that created the debt in the first place. This skill forces a product-first analysis: understand the value proposition, map the friction, then define constraints that prevent history from repeating. The output is optimized for LLM-driven re-development (Claude Code or similar).

---

## Workflow

### Phase 1: Clarification (Always Do This First)

Before analyzing anything, ask the user these questions to scope the work:

1. **Where is the codebase?** (local path, GitHub URL, or uploaded files)
2. **What were the top 3 technical blockers or frustrations?** — The things that motivated the rewrite. These become negative constraints.
3. **Any specific lessons learned?** (e.g., "should have used a relational DB", "state management was a nightmare", "the auth layer was bolted on")
4. **Target tech stack for the new version?** Or should you recommend one based on the analysis? If the user has preferences, capture them; if not, defer recommendation to the PRD.
5. **Scope boundaries** — Is the entire system being rewritten, or just specific modules?

Do not proceed to Phase 2 until you have answers (or explicit "skip" / "you decide").

### Phase 2: Codebase Analysis

Systematically extract intent from the legacy repo. Work through these steps in order. Adapting the pre-prepared scripts in `scripts/` as needed.

#### Step 2.1 — Structural Survey

Get the lay of the land:

```bash
bash scripts/structural-survey.sh
```

#### Step 2.2 — Intent Extraction

Identify **what the project accomplishes**:

- **Entry points**: `main.*`, `index.*`, `app.*`, route definitions, CLI parsers
- **API boundaries**: Route handlers, GraphQL schemas, RPC definitions, exported functions
- **Data models**: Database schemas, type definitions, interfaces, protobuf/OpenAPI specs
- **Test suites**: Test descriptions reveal expected behavior better than implementation code
- **Config files**: Environment variables, feature flags, service connections

Use grep/ripgrep patterns:

```bash
bash scripts/intent-extraction.sh
```

#### Step 2.3 — Friction Mapping

Identify what went wrong architecturally:

```bash
bash scripts/friction-mapping.sh
```

Cross-reference findings with the user's stated blockers from Phase 1.

#### Step 2.4 — Data Flow Mapping

Trace the critical paths:

- **Inputs**: What data enters the system? (HTTP requests, file uploads, CLI args, message queues, cron triggers)
- **Transformations**: What business logic is applied? (validation, computation, enrichment, aggregation)
- **Outputs**: What leaves the system? (API responses, rendered UI, reports, notifications, database writes)
- **Side effects**: External service calls, email sending, webhook triggers, audit logging

Document these as user-facing workflows, not implementation details.

### Phase 3: Generate the Rebirth Kit

Create a directory named `{PROJECT_NAME}_rebirth/` containing the artifacts below. Do **not** write any implementation code.

#### 3.1 — PRD.md

The PRD is the core blueprint. It must be structured for LLM parsing — use clear hierarchies, semantic headers, and explicit cross-references.

Use the template structure provided by `templates/PRD-template.md`

Every section must contain concrete detail from the analysis — no placeholders or generic advice. If a section can't be filled from the available data, mark it as `[REQUIRES INPUT]` with a note on what's needed.

#### 3.2 — CLAUDE.md

Development rules and tooling for the rebuild. This file is consumed by Claude Code (or equivalent) during re-development.

Use the template structure provided by `templates/CLAUDE-template.md`

#### 3.3 — standards.yaml

Architectural and linting rules in a machine-parseable format. Use YAML for readability with the template struture provided by `templates/standards-template.yaml`

### Phase 4: Review & Handoff

After generating the kit:

1. Present a summary of findings — key workflows discovered, major friction points, and the negative constraints derived from them.
2. Ask the user to review the PRD for accuracy — the analysis may have missed context that only a human familiar with the project would know.
3. Note any `[REQUIRES INPUT]` sections that need stakeholder decisions.
4. Suggest next steps: which workflow to build first, whether to prototype before committing to a stack, etc.

---

## Edge Cases & Guidance

- **Monorepos**: If the repo contains multiple packages/services, ask the user which ones are in scope. Generate a separate PRD section per service but a unified CLAUDE.md and standards config.
- **No tests in legacy repo**: Flag this prominently. Use API boundaries and data models as the primary source of behavioral requirements.
- **No README**: Lean harder on code analysis. The entry points and route definitions become the de facto requirements spec.
- **User provides GitHub URL**: Clone the repo locally first, then analyze.
- **User uploads a ZIP/tarball**: Extract and analyze.
- **User describes the project verbally**: Work from their description, but note in the PRD that requirements are based on stakeholder narrative, not code analysis. Recommend validation against the actual codebase if available.

## Tooling References

If the user is using Claude Code with the `everything-claude-code` plugin ecosystem (<https://github.com/affaan-m/everything-claude-code>), suggest relevant hooks, agents, sub-agents, skills, and commands:

- **Pre-commit**: Pattern-ban enforcement from `standards.yaml`
- **Custom commands**: Constraint checking, workflow tracing
- **MCP integrations**: If relevant tools are connected (GitHub, Jira, etc.), use them to enrich the analysis with issue history and PR context

---

## What This Skill Does NOT Do

- Write implementation code for the rebuild
- Make opinionated framework choices without user input
- Perform incremental refactoring of the existing codebase
- Generate migration scripts or data conversion tools

The output is a **blueprint**, not a build. The rebuild itself is a separate effort.
