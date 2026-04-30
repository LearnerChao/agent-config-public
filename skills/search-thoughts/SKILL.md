---
name: search-thoughts
description: >-
  Search across all journal files in <thoughts-dir>/ (default
  ~/code/thoughts/, see journal-config.local.mdc) for a keyword, concept,
  or topic and return a consolidated view. Use when the user says "search thoughts",
  "find in journal", "when did I work on", "have I noted anything about",
  "what did I write about", "have I seen this before", "grep journal",
  "look through my notes", "did I note", or asks to find something in their notes.
---

# Search Thoughts

Search across the full journal for a keyword or concept and present a consolidated timeline.

## Workflow

### 1. Determine search terms

Extract the keyword, phrase, or concept from the user's message. If the query is conceptual ("that streaming idea"), try multiple related search terms.

### 2. Search all journal files

Use grep/ripgrep to search across all files in `<thoughts-dir>/` (placeholder resolved by `journal-config.local.mdc`; default `~/code/thoughts/`). Substitute `<thoughts-dir>` with the configured absolute path when running the command — for example, with the default path:

```bash
rg -i --heading --line-number "SEARCH_TERM" ~/code/thoughts/
```

Search these file types:
- `daily/*.md`
- `ideas.md`
- `open-questions.md`
- `decisions.md`
- `til.md`
- `weekly/*.md`
- `projects/*.md`

### 3. Organize results

Group matches by source type and present chronologically:

```
## Search Results for "search term"

### Daily Entries
- **YYYY-MM-DD**: Matching context (session N)
- **YYYY-MM-DD**: Matching context

### Decisions
- **DEC-YYYY-MM-DD-N**: Decision summary

### Ideas
- **YYYY-MM-DD**: Idea text

### Open Questions
- **YYYY-MM-DD**: Question text

### TIL
- **YYYY-MM-DD**: What was learned

N total matches across M files.
```

### 4. Highlight connections

If the same concept appears across multiple categories (e.g., started as a question, became an idea, then a decision), call that out as a narrative thread.

This is a read-only operation — do not modify any files or commit.
