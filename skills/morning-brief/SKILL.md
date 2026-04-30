---
name: morning-brief
description: >-
  Generate a forward-looking daily brief from recent journal entries. Reviews
  open tasks, resurfaces ideas and parking-lot items, and suggests focus areas. Use when the user
  says "morning brief", "daily brief", "what should I work on", or "plan my day".
---

# Morning Brief

Generate a prioritized, forward-looking brief by reviewing recent daily journal entries, open questions, the ideas backlog, and the parking lot.

## Workflow

### 1. Gather recent context

Read the following files from `<thoughts-dir>/` (placeholder resolved by `journal-config.local.mdc`; default `~/code/thoughts/`):

- The **last 5 daily files** in `daily/` (sorted by filename descending). Use `ls` or glob to find them.
- `open-questions.md`
- `ideas.md`
- `parking-lot.md`
- `decisions.md` (last 10 entries only, for recent decision context)

If fewer than 5 daily files exist, read whatever is available.

### 2. Extract carryover tasks

Scan all read daily files for unchecked task items (`- [ ]`) in both the **Plan** and **Open items** sections of session entries. Collect them with their originating date.

Flag any item that appears across 3+ daily files as **stale**.

Also scan **session entries** (`### Session` blocks) for unchecked `- [ ]` items under `**Open items**:` — these are the primary source of real backlog, not just Plan items.

### 3. Build context restoration

For each distinct project mentioned in session entries from the last 3 days, write a 1-2 sentence summary of where that project left off: what was last done, and what the immediate next step is.

### 4. Surface ideas

Select 1-2 ideas from `ideas.md` that:
- Were recorded more than 3 days ago (giving them time to marinate)
- Have not been mentioned in the last 2 daily files (avoiding redundancy)
- Are **not** struck through (`~~...~~`) and do not have a lifecycle status annotation like `(implemented ...)`, `(dropped ...)`, or `(explored ...)`

Ideas with these annotations have already been triaged and should not be resurfaced. Only surface ideas that are still in their original, un-annotated state.

If no ideas qualify, skip this section.

### 5. Check open questions

List any open questions from `open-questions.md` that were added in the last 7 days and have not been resolved. Resolved questions use strikethrough format: `~~**date** [project]: question~~ — resolved YYYY-MM-DD: answer`. Skip those.

### 6. Surface parking lot

Read `parking-lot.md`. If it has entries, list up to 3 **most recent** (by date prefix) that are not struck through. If the file is empty or only comments, skip this section in the brief.

### 7. Generate the brief

Present the brief to the user conversationally with these sections:

```
## Morning Brief — YYYY-MM-DD

### Carryover Tasks
- [ ] Task from YYYY-MM-DD: description
- [ ] Task from YYYY-MM-DD: description (⚠️ stale — open 4 days)

### Where You Left Off
- **project-a**: Last worked on X. Next step: Y.
- **project-b**: Last worked on Z. Next step: W.

### Open Questions
- [project]: Question text (asked YYYY-MM-DD)

### Ideas to Revisit
- [project]: Idea text (captured YYYY-MM-DD)

### Parking Lot
- [project]: Deferred item (captured YYYY-MM-DD)

### Stale Items — Triage Needed
- [ ] Item text (open since MM-DD, ⚠️ 4 days) → escalate / resolve?

### Suggested Focus
Based on recency, staleness, and momentum, consider prioritizing:
1. First recommendation with brief rationale
2. Second recommendation
```

Only show the "Parking Lot" section if `parking-lot.md` has qualifying entries.

Only show the "Stale Items" section if there are items flagged as stale (3+ daily files). For each, suggest whether it should be **escalated** to a question (`open-questions.md`) or **resolved** (checked off).

**Friday retro nudge**: If today is Friday, append to the brief:

```
### Weekly Retro
It's Friday — consider running `/weekly-retrospective` to review this week before wrapping up.
```

### 8. Write today's plan

- Create today's `<thoughts-dir>/daily/YYYY-MM-DD.md` from the template if it does not exist.
- Write the carryover tasks into the `## Plan` section.
- Do not overwrite existing plan content if the file already exists and has plan items.

### 9. Git commit

Commit changes to `<thoughts-dir>/` with message: `brief: YYYY-MM-DD morning plan`
