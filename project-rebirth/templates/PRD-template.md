# {Project Name} — Product Requirements Document

## 1. Executive Summary

One paragraph: what does this product do and for whom?

## 2. Core Value Proposition

What problem does this solve? Why does it exist?
Strip away implementation — state this in user/business terms.

## 3. User Workflows

<!-- Aim for 3–7 workflows. For each: document the happy path AND the top 2 error/edge paths.
     Workflows should map to distinct user goals, not implementation layers. -->

### 3.N {Workflow Name}

- **Trigger**: What initiates this workflow (user action, scheduled event, incoming message)
- **Inputs**: Expected data or interaction (fields, file types, formats)
- **Process**: Business logic steps — state what must happen, not how. E.g.: "validate user identity, check account balance, deduct amount, emit confirmation"
- **Outputs**: What the user or downstream system receives
- **Success criteria**: How to verify correctness (observable outcome, not a test file path)
- **Error paths**: Top 2–3 failure modes and expected behavior (e.g., "invalid input → return 400 with field-level errors"; "downstream service unavailable → queue for retry, notify user")

## 4. Data Model

<!-- Format each entity as: name, attribute list (name + type + constraints), relationships (plain English),
     and lifecycle states. Example:
       **Order** — id (UUID, immutable), customerId (FK), status (enum: draft|submitted|fulfilled|cancelled),
       total (decimal, ≥ 0). Belongs to one Customer; has many OrderItems.
       Lifecycle: draft → submitted (on checkout) → fulfilled (on delivery) or cancelled (before fulfillment). -->

Describe entities, relationships, and invariants.
Use plain-language descriptions, not ORM syntax.
Include cardinality and lifecycle (created → active → archived).

## 5. Integration Points

<!-- For each integration, specify: purpose, data exchanged (in and out), failure behavior.
     Failure behavior format: "On timeout (>N ms): [retry N times with exponential backoff | degrade gracefully | fail fast]"
     Example:
       **Stripe Payments** — charges cards and issues refunds.
       Sends: amount, currency, customer token. Receives: payment intent ID, status.
       On failure: surface user-facing error "Payment could not be processed"; do not retry automatically. -->

External services, APIs, data sources the system depends on.
For each: purpose, data exchanged, failure modes (retry policy, timeout, fallback behavior).

## 6. Non-Functional Requirements

<!-- Include concrete targets where possible. Mark unknowns as [REQUIRES INPUT].
     Examples: API p95 latency < 200 ms under N concurrent users; 99.9% monthly uptime SLA;
     auth minimum: HTTPS + short-lived JWTs; WCAG 2.1 AA accessibility;
     GDPR: no PII stored beyond 90 days without consent. -->

- **Performance**: Response time targets, throughput expectations
- **Security**: Authentication standard, authorization model, data-at-rest/in-transit requirements
- **Accessibility**: Compliance level (WCAG 2.1 AA, etc.) if applicable
- **Scalability**: Expected load range; horizontal vs. vertical scaling expectations
- **Compliance**: Regulatory requirements (GDPR, HIPAA, SOC 2, etc.) if applicable

## 7. Lessons Learned from Legacy Implementation

### 7.1 What Worked

Patterns, libraries, or approaches worth preserving.

### 7.2 What Failed

Specific architectural decisions that caused friction.
Include the *why* — not just "Redux was bad" but
"global state via Redux created coupling between unrelated features, making isolated testing impossible."

## 8. Negative Constraints (Anti-Requirements)

<!-- These feed directly into CLAUDE.md Prohibited Patterns and standards.yaml banned_patterns.
     Each entry MUST have all three fields — no entry without a "Preferred alternative". -->

Explicit patterns, dependencies, or approaches that are BANNED in the rebuild. Each must include:

- **What**: The specific pattern/dependency (be precise — e.g., "synchronous DB calls in request handlers", not just "slow DB")
- **Why banned**: What problem it caused in the legacy system
- **Preferred alternative**: What to do instead (e.g., "use async/await with connection pooling")

## 9. Open Questions

<!-- Each question needs a priority:
       - [BLOCKING] — must be resolved before implementation begins
       - [NON-BLOCKING] — can be decided incrementally during development
     Example:
       - [BLOCKING] Do we support multi-tenancy from day one? This affects the entire data model schema.
       - [NON-BLOCKING] Which CI/CD provider? Doesn't affect application design. -->

Unresolved decisions that need stakeholder input before building.

## 10. Success Metrics

How to measure whether the rebuild achieved its goals.
Include both technical (e.g., latency reduction, error rate) and business (e.g., user task completion rate) metrics.
