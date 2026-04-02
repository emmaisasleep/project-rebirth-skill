# project-rebirth

A Cursor / Claude Code skill that reverse-engineers a legacy codebase into a **Rebirth Kit** — a clean-slate architecture package containing a PRD, CLAUDE.md, and standards config — preserving business logic while discarding technical debt.

## What it does

`project-rebirth` runs a four-phase workflow against any existing repo:

1. **Clarification** — asks scoping questions (blockers, lessons learned, target stack, scope boundaries) before touching any code
2. **Codebase Analysis** — runs four analysis scripts to extract structure, intent, friction points, and data flows from the legacy repo
3. **Rebirth Kit generation** — produces a `{PROJECT_NAME}_rebirth/` directory containing a PRD, a CLAUDE.md, and a `standards.yaml`
4. **Review & Handoff** — summarises findings, flags `[REQUIRES INPUT]` sections that need stakeholder decisions, and suggests where to start the rebuild

The output is a **blueprint**, not a build. No implementation code is written.

## When to trigger it

Use this skill when you want to:

- Rewrite or rebuild a project from scratch
- Extract requirements from a legacy codebase
- Create a PRD from an existing repo
- Understand what a codebase actually does
- Audit a repo for technical debt before rewriting
- Generate a CLAUDE.md for a rebuild

Trigger phrases the skill recognises: _"Start over"_, _"Rewrite this"_, _"Rebuild from scratch"_, _"Clean slate"_, _"Rebirth"_, _"Extract the requirements"_, _"Make a PRD from this repo"_, _"What does this codebase actually do"_.

Do **not** use for incremental refactoring, bug fixes, or feature additions to an existing codebase.

## Installation

Copy or symlink the `project-rebirth/` folder into your Cursor skills directory:

```bash
# User-level (available in all projects)
cp -r project-rebirth ~/.cursor/skills/

# Or project-level
cp -r project-rebirth /path/to/your-project/.cursor/skills/
```

Cursor will automatically pick up the skill from `SKILL.md` on the next session.

## Output

Running the skill against a target repo produces a `{PROJECT_NAME}_rebirth/` directory:

```text
myapp_rebirth/
  PRD.md           # Product Requirements Doc — workflows, data model, NFRs, lessons learned
  CLAUDE.md        # Rebuild rules — stack conventions, prohibited patterns, rebuild sequence
  standards.yaml   # Machine-parseable architectural and linting constraints
```

Every placeholder in the templates is replaced with concrete findings from the analysis. Sections that cannot be resolved from the code are marked `[REQUIRES INPUT]` with a note on what stakeholder input is needed.

## Repo layout

```text
project-rebirth-skill/
  project-rebirth/
    SKILL.md                      # Executable skill definition (frontmatter + workflow)
    scripts/
      structural-survey.sh        # Phase 2.1: file tree + package manifests
      intent-extraction.sh        # Phase 2.2: routes, models, tests, env vars
      friction-mapping.sh         # Phase 2.3: debt markers, complexity, dependency bloat
      data-flow.sh                # Phase 2.4: inputs, transformations, outputs, side effects
    templates/
      PRD-template.md             # Output template for the Product Requirements Doc
      CLAUDE-template.md          # Output template for the rebuild's CLAUDE.md
      standards-template.yaml     # Output template for architectural/linting rules
```

The analysis scripts run against the **target (legacy) repo**, not this repo. They use `rg` (ripgrep) and standard Unix tools and are designed to be adapted for different languages and project structures.

## What it does not do

- Write implementation code for the rebuild
- Make opinionated framework choices without user input
- Perform incremental refactoring of the existing codebase
- Generate migration scripts or data conversion tools
