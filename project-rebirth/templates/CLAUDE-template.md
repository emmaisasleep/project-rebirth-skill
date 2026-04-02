# CLAUDE.md — {Project Name} Rebuild

## Project Context

{Brief: what this project is and why it's being rebuilt.}
Full requirements: see [PRD.md](./PRD.md).
Machine-parseable rules: see [standards.yaml](./standards.yaml).

## Development Rules

### Mandatory

<!-- Format: statement of rule — rationale (cross-reference to PRD section).
     Examples:
       - No direct database queries outside the repository layer — PRD §5 mandates testable, swappable data access.
       - All HTTP calls to external services must go through the integration layer in src/integrations/ — PRD §5 failure modes require centralized retry/timeout logic.
     -->

- {Rule derived from lesson learned, with rationale — see PRD §7.2}
- {Rule derived from negative constraint — see PRD §8.N}

### Style & Conventions

- {Naming conventions — e.g., "kebab-case filenames, PascalCase classes, camelCase functions"}
- {File organization — e.g., "feature-based modules: src/{feature}/index, service, repository, types"}
- {Error handling — e.g., "errors bubble up to the request boundary; never swallow; always log with context"}

## Allowed CLI Commands

Commands safe to run during development (Claude Code will not prompt for these):

- `{build command}` — compile/bundle
- `{test command}` — run tests
- `{lint command}` — lint and type-check
- `{dev server command}` — start local dev server

## Prohibited Patterns

Derived from PRD §8. MUST NOT appear anywhere in the codebase:

<!-- Format: pattern-description: why it's banned (see PRD §8.N).
     Example:
       - Raw SQL strings in application code: leads to injection risk and untestable data access (see PRD §8.1).
       - Global mutable state: caused cross-feature coupling in legacy system (see PRD §8.2).
     -->

- {pattern}: {why it's banned — see PRD §8.N}

## Pre-Commit Hooks (Suggested)

Hooks that enforce quality standards automatically:

- lint-staged: run linter and formatter on staged files
- {pattern-ban check}: fail if any prohibited patterns are detected (see standards.yaml `banned_patterns`)
- {type check}: fail on type errors before commit

## Custom Slash Commands (Suggested)

For Claude Code workflows:

- `/check-constraints` — verify no banned patterns have crept in (cross-reference standards.yaml)
- `/trace-flow {workflow}` — walk through a user workflow end-to-end from PRD §3

## Testing Strategy

- **Coverage target**: {N}% minimum — align with standards.yaml `testing.minimum_coverage`
- **Priority**: implement tests for critical paths from PRD §3 first (especially §3.N workflows with complex error paths)
- **Integration tests**: required for each external integration in PRD §5 — test failure modes, not just happy paths
- **Test file location**: {co-located with source / centralized in tests/}
- **E2E**: {playwright/cypress/other} covering the top {N} user workflows from PRD §3

## Rebuild Sequence

Suggested implementation order based on dependency analysis.
Build in this order to avoid having to retrofit foundational decisions:

1. {Foundation layer — e.g., "data model + repository interfaces (no implementations yet)"}
2. {Core business logic — e.g., "service layer against repository interfaces, fully unit-tested"}
3. {Integration points — e.g., "repository implementations + external service adapters"}
4. {API/UI surface — e.g., "route handlers, request validation, response serialization"}
5. {Infrastructure — e.g., "auth middleware, rate limiting, observability"}

---
<!-- The standards.yaml file is the machine-parseable version of the constraints in this file.
     Keep them in sync: if you add a prohibited pattern here, add it to standards.yaml banned_patterns too. -->
