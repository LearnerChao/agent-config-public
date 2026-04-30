---
name: log-decision
description: >-
  Record a technical or project decision with context, alternatives, and
  rationale in <thoughts-dir>/decisions.md (default ~/code/thoughts/, see
  journal-config.local.mdc). Use when the user says
  "log decision", "decision:", "we decided", "record this decision",
  "decided to", "let's go with", "made the call", "going with option",
  or asks to document a choice that was made.
---

# Log Decision

Capture a structured decision record in the journal.

## Workflow

### 1. Extract the decision

From the conversation or user's message, identify:

- **Decision**: What was decided (one clear sentence)
- **Alternatives considered**: What other options were on the table
- **Rationale**: Why this alternative was chosen
- **Project**: Which project this relates to (infer from context if not stated)
- **Consequences**: Any known trade-offs or follow-up work implied by this choice

If any of these are unclear, ask the user briefly. Do not require all fields — alternatives and consequences can be "None noted" if truly not applicable.

### 2. Generate a decision ID

Use the format `DEC-YYYY-MM-DD-N` where N is a sequential number. Read `<thoughts-dir>/decisions.md` to find the highest existing N for today's date, then increment. If none exist for today, use 1.

### 3. Append to decisions.md

Append to `<thoughts-dir>/decisions.md`:

```markdown

### DEC-YYYY-MM-DD-N — Short title
**Date**: YYYY-MM-DD | **Project**: project-name
**Decision**: What was decided
**Alternatives**: What else was considered
**Rationale**: Why this choice
**Consequences**: Known trade-offs or follow-up work
```

### 4. Cross-reference with daily file

If today's `<thoughts-dir>/daily/YYYY-MM-DD.md` exists and has session entries, no separate annotation is needed — the session-summarize skill will pick up the decision at wrap-up.

### 5. Confirm and commit

- Tell the user: "Logged DEC-YYYY-MM-DD-N: short title"
- Git commit with message: `decision: DEC-YYYY-MM-DD-N short title`
