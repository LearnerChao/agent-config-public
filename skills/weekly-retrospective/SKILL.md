---
name: weekly-retrospective
description: >-
  Generate a weekly retrospective by reviewing the week's daily journal entries.
  Summarizes accomplishments, unresolved items, patterns, ideas, and decisions.
  Use when the user says "weekly retro", "week in review", "weekly summary",
  or "retrospective".
---

# Weekly Retrospective

Synthesize a week of daily journal entries into a structured retrospective.

## Workflow

### 1. Determine the target week

- Default to the current ISO week (Monday through Sunday).
- If today is Monday or Tuesday, ask the user whether they mean this week or last week.
- If the user specifies a week (e.g., "last week", "week of March 17"), use that.

Compute the date range: Monday YYYY-MM-DD through Sunday YYYY-MM-DD.

### 2. Read daily files

Read all daily files from `<thoughts-dir>/daily/` (placeholder resolved by `journal-config.local.mdc`; default `~/code/thoughts/`) whose dates fall within the target week. If no files exist for the week, tell the user and stop.

### 3. Extract and synthesize

From all session entries across the week, extract:

**Accomplishments**: Things that were completed. Combine related items across sessions. Group by project.

**Unresolved items**: Tasks marked `- [ ]` that were never checked off during the week. Flag items that appeared on multiple days.

**Patterns & Observations**:
- Which projects consumed the most sessions?
- Were there recurring blockers or context switches?
- Any themes in the types of work done (debugging, building, reviewing, planning)?

**Ideas generated**: Collect all ideas from session entries and from `<thoughts-dir>/ideas.md` entries dated within the week.

**Decisions made**: Collect all decisions from session entries and from `<thoughts-dir>/decisions.md` entries dated within the week.

### 4. Write the retrospective

Create `<thoughts-dir>/weekly/YYYY-WNN.md` with:

```markdown
# Week WNN — YYYY (Mon YYYY-MM-DD to Sun YYYY-MM-DD)

## Accomplishments
- **project-a**: What was accomplished
- **project-b**: What was accomplished

## Unresolved Items
- [ ] Item from MM-DD: description (⚠️ appeared 3 times this week)
- [ ] Item from MM-DD: description

## Patterns & Observations
- Observation about the week's work patterns
- Another observation

## Ideas Generated
- [project]: Idea text (MM-DD)

## Decisions Made
- [project]: Decision summary (MM-DD)
```

### 5. Present and commit

- Present a conversational summary highlighting the top 3 accomplishments and any concerning patterns (stale items, heavy context switching).
- Git commit with message: `retro: YYYY-WNN weekly retrospective`
