---
name: session-summarize
description: >-
  Summarize the current agent session and append it to the daily journal in
  <thoughts-dir>/ (default ~/code/thoughts/, see journal-config.local.mdc).
  Use when the user says "summarize session", "wrap up",
  "end of day", "log this session", or asks to record what was accomplished.
---

# Session Summarize

Capture a structured summary of the current conversation and append it to today's daily journal file.

## Workflow

### 1. Extract from this conversation only

Review **only this agent conversation** (the current chat session) and extract. Do NOT include work from earlier sessions today or prior days — even if you read those entries later to determine session numbering. The daily file is read for structure only; its content must not influence what you extract here.

- **Project(s)** worked on (infer from file paths, repo names, or explicit mentions)
- **Tasks completed** — concrete things that got done
- **Decisions made** — choices between alternatives, with rationale
- **Open items** — unfinished work, next steps, blockers
- **Ideas** — speculative thoughts, future possibilities, "what if" moments
- **TILs** — anything the user learned or discovered
- **Questions raised** — unresolved questions that came up

Be intelligent about classification. A decision is a deliberate choice between alternatives. An idea is speculative. An open item is concrete unfinished work.

### 2. Read or create today's daily file

> **Scope reminder**: The daily file may contain prior session entries. Those are context for numbering and dedup only — do not merge their content into the current session's summary.

- Determine today's date in `YYYY-MM-DD` format.
- Check if `<thoughts-dir>/daily/YYYY-MM-DD.md` exists (placeholder resolved by `journal-config.local.mdc`; default `~/code/thoughts/`).
- If it does not exist, create it from the template:

```markdown
# YYYY-MM-DD

## Plan

## Sessions
```

### 3. Determine session number and time

- Read today's daily file and scan for all existing `### Session N` headings.
- Parse the session numbers and find the maximum. The next session number is max + 1. If none exist, use 1.
- Before writing, verify no existing session block contains the same project and substantially similar summary content. If a near-duplicate exists, skip the write and inform the user that this session appears already logged.
- Use the current time (HH:MM) for the timestamp.

### 4. Append the session entry

Insert a new session block under `## Sessions` using this format:

```markdown
### Session N — HH:MM
**Project**: project-name
**Summary**: One to three sentences describing what was accomplished.
**Decisions**: Brief description of decisions made, or "None" if none.
**Open items**:
- [ ] Concrete next step or unfinished task
- [ ] Another item
**Ideas**: Any ideas that came up, or "None" if none.
```

If multiple projects were worked on, list them comma-separated in the Project field and organize the summary by project.

### 5. Cross-post to persistent files

- If **ideas** were extracted, append each to `<thoughts-dir>/ideas.md`:
  ```
  - **YYYY-MM-DD** [project-name]: The idea text
  ```
- If **decisions** were made, append each to `<thoughts-dir>/decisions.md`:
  ```
  ### DEC-YYYY-MM-DD-N — Short title
  **Date**: YYYY-MM-DD | **Project**: project-name
  **Decision**: What was decided
  **Alternatives**: What else was considered
  **Rationale**: Why this choice was made
  ```
- If **TILs** were captured, append each to `<thoughts-dir>/til.md`:
  ```
  - **YYYY-MM-DD**: What was learned
  ```
  Do NOT also write TILs to the daily file — `til.md` is the single canonical home to avoid duplication. (Optional scratch goes under `## Notes` in the daily template if needed.)
- If **open questions** were raised, append each to `<thoughts-dir>/open-questions.md`:
  ```
  - **YYYY-MM-DD** [project-name]: The question
  ```

### 6. Resolve answered questions

Read `<thoughts-dir>/open-questions.md` and check whether this session's work resolves any existing open questions. A question is resolved if the session directly answers it, implements a fix for it, or renders it moot.

For each resolved question, update its entry in `open-questions.md` from:
```
- **YYYY-MM-DD** [project]: The question
```
to:
```
- ~~**YYYY-MM-DD** [project]: The question~~ — resolved YYYY-MM-DD: brief answer
```

Mention resolved questions in the user-facing summary so they can confirm.

### 7. Review and promote stale open items

Scan today's daily file for unchecked `- [ ]` items from **previous sessions** (not the one just written). For each item open across 2+ sessions or 2+ days:

- Present them to the user in a batch and ask for each: **resolve** (check it off), **escalate** (move to `open-questions.md`), or **carry** (leave as-is for next session).
- For escalated items, append to `<thoughts-dir>/open-questions.md`:
  ```
  - **YYYY-MM-DD** [project]: Item text
  ```
- Check off resolved items in the daily file.

If no stale items exist, skip silently.

### 8. Auto-create project file

Check whether a `<thoughts-dir>/projects/{project-name}.md` file exists for each project worked on in this session. If not, scan today's daily file and the last 5 daily files for sessions mentioning this project. If the project appears in 3 or more sessions across any daily files and has no project file, create a stub at `<thoughts-dir>/projects/{project-name}.md`:

```markdown
# {Project Name}

> Auto-created YYYY-MM-DD after {N} sessions.

## Status

Active — last session YYYY-MM-DD.

## Summary

{1-2 sentence synthesis of what this project is about, derived from session summaries.}

## Key Decisions

{List key decisions from decisions.md tagged with this project, or "None yet."}

## Open Items

{Collect unchecked items from recent sessions, or "None."}
```

Tell the user the project file was created so they can review and edit it.

### 9. Git commit

Stage and commit all changed files in `<thoughts-dir>/` with a message like:

```
session: project-name — short summary of what was done
```

### 10. Present summary to user

After writing, display a brief confirmation showing:
- Session number and timestamp
- One-line summary
- Count of open items, ideas, and decisions captured
