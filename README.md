# Cursor Config

Agent skills, subagent definitions, and rules for the [Cursor](https://cursor.com) IDE.

This is the public subset of a larger private configuration. Skills and agents are designed to be generic and reusable.

## Quick Start

```bash
git clone https://github.com/joshuacherry/cursor-config-public.git ~/code/cursor-config-public
cd ~/code/cursor-config-public
chmod +x install.sh
./install.sh
```

The install script creates symlinks from Cursor's expected locations into this repo and bootstraps a per-user journal config at `rules/journal-config.local.mdc` (gitignored).

To use a journal directory other than `~/code/thoughts/` from the start:

```bash
./install.sh --thoughts-dir=/path/to/your/journal
# or
THOUGHTS_DIR=/path/to/your/journal ./install.sh
```

You can change the path later by editing `~/.cursor/rules/journal-config.local.mdc`. See [Customization](#customization) for details.

## What's Included

### Skills

Skills are agent capabilities invoked by natural language triggers.

| Skill | Description |
|---|---|
| `capture-thought` | Capture thoughts, ideas, questions, and TILs into a journal |
| `critical-review` | Devil's advocate review of code, designs, proposals, or plans |
| `greenhouse-prep` | Structured Greenhouse interview feedback from raw notes |
| `implement-from-spec` | Sprint-style implementation from a specification file |
| `log-decision` | Record technical decisions with context and rationale |
| `morning-brief` | Daily brief from recent journal entries |
| `project-context-restore` | Restore context for a project after time away |
| `review-cursor-setup` | Audit Cursor setup (skills, rules, agents, MCP) |
| `search-thoughts` | Search across journal files for a keyword or topic |
| `session-summarize` | Summarize the current session and append to daily journal |
| `spec-refiner` | Iteratively refine ideas into actionable specifications |
| `standup-report` | Generate a standup report from journal entries |
| `swarm-orchestrator` | Orchestrate parallel subagents for complex tasks |
| `sync-config` | Commit and push config repo changes |
| `weekly-retrospective` | Weekly retrospective from daily journal entries |

### Agents

Custom subagent definitions used by skills like `spec-refiner` and `swarm-orchestrator`.

| Agent | Role |
|---|---|
| `spec-critic` | Adversarial reviewer for specifications |
| `spec-questioner` | Asks clarifying questions about specs |
| `spec-researcher` | Researches enterprise context for specs |
| `swarm-implementer` | Implements tasks in parallel swarm workflows |
| `swarm-researcher` | Researches codebase context for swarm tasks |
| `swarm-reviewer` | Reviews implementations in swarm workflows |
| `swarm-tester` | Writes and runs tests in swarm workflows |
| `swarm-validator` | Validates completed swarm work |

### Rules

Global Cursor rules (`.mdc` files) that provide persistent context.

| Rule | Description |
|---|---|
| `thoughts-aware` | Makes the agent aware of the user's thoughts journal (path configurable; see [Customization](#customization)) |
| `web-scraping` | Decision tree and CLI reference for web scraping tasks |

The thoughts journal path is configured by `journal-config.local.mdc`, which is generated from `journal-config.example.mdc` by the install script and gitignored so each user can customize it independently.

### MCP Template

`mcp-template.json` provides a starting point for MCP server configuration. Replace the placeholder URLs with your own endpoints.

## Symlink Map

After running `install.sh`:

- `~/.cursor/skills` -> `skills/`
- `~/.cursor/agents` -> `agents/`
- `~/.cursor/rules` -> `rules/`

## Journal System

Several skills reference a journal whose path is set by `journal-config.local.mdc` (default `~/code/thoughts/`). Skills and rules in this repo refer to the journal as `<thoughts-dir>/`; the agent expands that placeholder using the configured path. The expected directory structure:

```
<thoughts-dir>/
  daily/YYYY-MM-DD.md    # daily session logs
  ideas.md               # idea backlog
  open-questions.md      # unresolved questions
  decisions.md           # decision log
  til.md                 # things learned
  parking-lot.md         # deferred items
  projects/              # per-project notes
  weekly/                # weekly retrospectives
```

Create this directory structure to use journal-related skills, or adapt the skills to your own system.

## Customization

- **Thoughts journal path**: edit the path in `~/.cursor/rules/journal-config.local.mdc` (created by `install.sh` from `journal-config.example.mdc`). To set the path during initial install, pass `--thoughts-dir=/your/path` or set `THOUGHTS_DIR=/your/path`. The local config is gitignored, so personal paths never end up in the repo. If `journal-config.local.mdc` is absent (e.g., you skipped `install.sh`), each skill still names `~/code/thoughts/` as the inline default, so journal-related skills keep working — just without per-user configurability until you create the local config.
- **Add your own skills**: Create `skills/<name>/SKILL.md` and they'll be picked up by Cursor.
- **MCP servers**: Copy `mcp-template.json` to `~/.cursor/mcp.json` and fill in your endpoints.
- **Rules**: Add `.mdc` files to `rules/` for persistent agent context. Files matching `rules/*.local.mdc` are gitignored — useful for any per-user config you want kept out of the repo.

## License

MIT
