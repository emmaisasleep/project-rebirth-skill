# CLAUDE.md — {Project Name} Rebuild

## Project Context

Brief: what this project is, link to PRD.md for full requirements.

## Development Rules

### Mandatory

- {Rule derived from lesson learned, with rationale}
- {Rule derived from negative constraint}
- ...

### Style & Conventions

- {Naming conventions}
- {File organization patterns}
- {Error handling approach}
- ...

## Allowed CLI Commands

Commands that are safe to run during development:

- `{command}` — {purpose}

## Prohibited Patterns

Patterns that MUST NOT appear in the codebase (derived from §8 of PRD):

- {pattern}: {why it's banned}

## Pre-Commit Hooks (Suggested)

Hooks that enforce quality standards automatically:

- {hook}: {what it checks}

## Custom Slash Commands (Suggested)

For Claude Code workflows:

- `/check-constraints` — Verify no banned patterns have crept in
- `/trace-flow {workflow}` — Walk through a user workflow from PRD §3

## Testing Strategy

- Minimum coverage expectations
- What to test first (critical paths from PRD §3)
- Integration test approach for external services (PRD §5)

## Rebuild Sequence

Suggested order of implementation based on dependency analysis:

1. {Foundation layer}
2. {Core business logic}
3. {Integration points}
4. {UI/API surface}
