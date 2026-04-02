# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

This is a **Claude Code skill definition** — not an application. It packages the `project-rebirth` skill, which reverse-engineers an existing codebase into a "Rebirth Kit" (PRD, CLAUDE.md, standards config) for clean-slate rebuilds.

The skill is invoked via `/project-rebirth` in Claude Code sessions. It is consumed by the `everything-claude-code` plugin ecosystem.

## Repository Structure

```text
project-rebirth-skill/
  SKILL.md                    # Skill definition (frontmatter + workflow instructions)
  scripts/
    structural-survey.sh      # Phase 2.1: file tree + package manifests
    intent-extraction.sh      # Phase 2.2: routes, models, tests, env vars
    friction-mapping.sh       # Phase 2.3: debt markers, file complexity, deps
  templates/
    PRD-template.md           # Output template for the Product Requirements Doc
    CLAUDE-template.md        # Output template for the rebuild's CLAUDE.md
    standards-template.yaml   # Output template for architectural/linting rules
```

## Skill Anatomy

`SKILL.md` is the executable definition. Its YAML frontmatter declares the skill `name`, `description`, and trigger phrases. The body defines the four-phase workflow:

1. **Clarification** — ask scoping questions before touching any code
1. **Codebase Analysis** — run scripts, extract intent, map data flows
1. **Generate Rebirth Kit** — produce `{PROJECT_NAME}_rebirth/` with PRD.md, CLAUDE.md, standards.yaml
1. **Review & Handoff** — summarize findings, flag `[REQUIRES INPUT]` sections

## Scripts

The three analysis scripts are run against the **target (legacy) repo**, not this repo. They use `rg` (ripgrep) and standard Unix tools. They are designed to be adapted — if the target repo uses a different language or structure, modify the patterns before running.

## Templates

Templates use `{PLACEHOLDER}` syntax. Every placeholder must be replaced with concrete findings from the analysis — never leave generic placeholder text in generated output. Sections that cannot be filled from code analysis must be marked `[REQUIRES INPUT]` with a note on what stakeholder input is needed.

## Working with This Skill

When modifying the skill:

- Changes to the **workflow logic** go in `SKILL.md`
- Changes to **analysis heuristics** go in the relevant `scripts/*.sh`
- Changes to **output structure** go in the relevant `templates/`
- The skill does **not** write implementation code — output is blueprints only

To add support for a new language in the analysis scripts, extend the `--type-add` patterns in `intent-extraction.sh` and the `find` patterns in `friction-mapping.sh`.
