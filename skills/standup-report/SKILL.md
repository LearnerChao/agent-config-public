---
name: standup-report
description: >-
  Generate a standup report from yesterday's journal and today's plan, formatted
  for pasting into Slack or a standup tool. Use when the user says "standup",
  "standup report", "generate standup", "daily update", "what's my standup",
  or "what did I do yesterday".
---

# Standup Report

Generate a concise standup from the daily journal, ready to paste into Slack or a standup tool.

## Workflow

### 1. Gather inputs

- Read yesterday's daily file: `<thoughts-dir>/daily/YYYY-MM-DD.md` (placeholder resolved by `journal-config.local.mdc`; default `~/code/thoughts/`). Use the most recent file before today if yesterday has no file (e.g., Friday's file on a Monday).
- Read today's daily file if it exists (for the Plan section).

### 2. Build the standup

Extract and format into three sections:

```
**Yesterday**
- Completed task or accomplishment (project-name)
- Another item

**Today**
- Planned task from today's Plan section
- Carryover item from yesterday's open items

**Blockers**
- Any blocker mentioned in yesterday's open items or flagged explicitly
- "None" if no blockers
```

### 3. Formatting rules

- Keep each bullet to one line, under 100 characters.
- Lead with the verb: "Implemented...", "Debugged...", "Reviewed...".
- Include the project name in parentheses if multiple projects are active.
- Total standup should be 5-10 lines. Consolidate if there were many small items.

### 4. Present to user

Display the formatted standup in a code block so it can be easily copied. Do not commit anything to git — this is a read-only report.
