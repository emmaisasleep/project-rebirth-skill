# {Project Name} — Product Requirements Document

## 1. Executive Summary

One paragraph: what does this product do and for whom?

## 2. Core Value Proposition

What problem does this solve? Why does it exist?
Strip away implementation — state this in user/business terms.

## 3. User Workflows

For each major workflow:

### 3.N {Workflow Name}

- **Trigger**: What initiates this workflow
- **Inputs**: Expected data/interaction
- **Process**: Business logic steps (not code steps)
- **Outputs**: What the user/system receives
- **Success criteria**: How to verify correctness

## 4. Data Model

Describe entities, relationships, and invariants.
Use plain-language descriptions, not ORM syntax.
Include cardinality and lifecycle (created → active → archived).

## 5. Integration Points

External services, APIs, data sources the system depends on.
For each: purpose, data exchanged, failure modes.

## 6. Non-Functional Requirements

Performance targets, security requirements, accessibility,
scalability expectations, compliance needs.

## 7. Lessons Learned from Legacy Implementation

### 7.1 What Worked

Patterns, libraries, or approaches worth preserving.

### 7.2 What Failed

Specific architectural decisions that caused friction.
Include the *why* — not just "Redux was bad" but
"global state via Redux created coupling between unrelated features."

## 8. Negative Constraints (Anti-Requirements)

Explicit patterns, dependencies, or approaches that are BANNED
in the rebuild. Each must include:

- **What**: The specific pattern/dependency
- **Why banned**: What problem it caused
- **Preferred alternative**: What to do instead

## 9. Open Questions

Unresolved decisions that need stakeholder input before building.

## 10. Success Metrics

How to measure whether the rebuild achieved its goals.
