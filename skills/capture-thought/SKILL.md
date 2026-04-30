---
name: capture-thought
description: >-
  Quickly capture a thought, idea, question, bookmark, or TIL into the
  appropriate journal file in <thoughts-dir>/ (default ~/code/thoughts/, see
  journal-config.local.mdc). Also handles idea lifecycle
  updates (explored, implemented, dropped). Use when the user says
  "thought:", "idea:", "question:", "capture this", "note to self",
  "remember this", "TIL", "bookmark", "jot this down", "log this",
  "save this thought", "parking:", "explored:", "implemented:", or "dropped:".
---

# Capture Thought

Quickly classify and persist a thought into the appropriate file in `<thoughts-dir>/` (placeholder resolved by `journal-config.local.mdc`).

## Workflow

### 1. Parse and classify

From the user's message, extract the content and classify it into one of:

| Category | Signals | Target file |
|----------|---------|-------------|
| **Idea** | "idea", speculative, "what if", "could we", future possibility | `ideas.md` |
| **Question** | "?", "why does", "how do", "I wonder", needs investigation | `open-questions.md` |
| **TIL** | "TIL", "learned that", "discovered", "turns out" | `til.md` |
| **Bookmark** | URL, "check out", "read later", "interesting article" | `ideas.md` (tagged as bookmark) |
| **Parking** | "parking", "out of scope", "not now", "defer", "later" (explicitly shelved work) | `parking-lot.md` |
| **Observation** | General thought, reflection, none of the above | `til.md` |

If the user explicitly prefixes with a category (e.g., "idea: ..."), use that. Otherwise, infer from content.

### 2. Determine project context

If the current conversation involves a specific project (inferred from open files, repo paths, or explicit mention), tag the entry with that project name. Otherwise, omit the project tag.

### 3. Append to the target file

**For ideas.md, open-questions.md, til.md, parking-lot.md:**

```markdown
- **YYYY-MM-DD** [project-name]: The captured text
```

Omit the `[project-name]` bracket if no project context is available.

**For bookmarks (appended to ideas.md):**

```markdown
- **YYYY-MM-DD** 📎 [project-name]: Description — URL
```

**For observations (appended to til.md):**

```markdown
- **YYYY-MM-DD** [project-name]: The observation text
```

### 4. Idea lifecycle updates

When the user says "explored:", "implemented:", or "dropped:" followed by an idea reference, find the matching idea in `ideas.md` and append a status annotation:

- `(explored YYYY-MM-DD)` — looked into but no action taken yet
- `(implemented via DEC-YYYY-MM-DD-N)` — built or decided on
- `(dropped: reason)` — explicitly abandoned

Ideas with status annotations are filtered out of morning-brief resurfacing.

### 5. Confirm and commit

- Tell the user what was captured and where it was filed (one sentence).
- Git commit the change in `<thoughts-dir>/` with message: `capture: short description`
