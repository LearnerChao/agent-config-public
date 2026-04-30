# Agent Config

Agent skills, subagent definitions, and rules for AI coding IDEs that follow the [Agent Skills](https://agentskills.io/) open standard. Currently supports **Cursor**, **Claude Code**, **Codex CLI**, and **Gemini CLI** (best-effort).

This is the public subset of a larger private configuration. Skills and agents are designed to be generic and reusable across IDEs.

## Quick Start

```bash
git clone https://github.com/LearnerChao/agent-config-public.git ~/code/agent-config-public
cd ~/code/agent-config-public
chmod +x install.sh
./install.sh
```

The install script presents an interactive list of supported IDEs (with installed ones pre-selected) and creates symlinks into the IDEs you choose. To skip the prompt:

```bash
./install.sh --ide=cursor                   # one IDE
./install.sh --ide=cursor,claude            # multiple
./install.sh --ide=auto                     # only IDEs detected on this machine
./install.sh --ide=all                      # every supported IDE
```

To set your thoughts journal path during install (default `~/code/thoughts/`):

```bash
./install.sh --ide=auto --thoughts-dir=/path/to/your/journal
# or
THOUGHTS_DIR=/path/to/your/journal ./install.sh --ide=auto
```

You can change the path later by editing `rules/journal-config.local.mdc` (which is symlinked into your IDE's rules directory). See [Customization](#customization) for details.

## What's Included

### Skills

Skills are agent capabilities invoked by natural language triggers. Each skill is a `SKILL.md` with frontmatter; the format follows the [Agent Skills open standard](https://agentskills.io/) and works across Cursor, Claude Code, Codex CLI, and Gemini CLI.

| Skill | Description |
|---|---|
| `capture-thought` | Capture thoughts, ideas, questions, and TILs into a journal |
| `critical-review` | Devil's advocate review of code, designs, proposals, or plans |
| `greenhouse-prep` | Structured Greenhouse interview feedback from raw notes |
| `implement-from-spec` | Sprint-style implementation from a specification file |
| `log-decision` | Record technical decisions with context and rationale |
| `morning-brief` | Daily brief from recent journal entries |
| `project-context-restore` | Restore context for a project after time away |
| `review-agent-setup` | Audit your agent setup (skills, rules, agents, MCP) across installed IDEs |
| `search-thoughts` | Search across journal files for a keyword or topic |
| `session-summarize` | Summarize the current session and append to daily journal |
| `spec-refiner` | Iteratively refine ideas into actionable specifications |
| `standup-report` | Generate a standup report from journal entries |
| `swarm-orchestrator` | Orchestrate parallel subagents for complex tasks |
| `sync-config` | Commit and push agent-config repo changes |
| `weekly-retrospective` | Weekly retrospective from daily journal entries |

### Agents

Custom subagent definitions used by skills like `spec-refiner` and `swarm-orchestrator`. Cursor and Claude Code load these from their respective `agents/` directories. Codex CLI and Gemini CLI don't have a separate subagent concept yet, so the install script skips the agents symlink for those IDEs.

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

Persistent agent context as `.mdc` files. The frontmatter is Cursor-flavored (`alwaysApply`, `globs`); Claude Code reads `.mdc` files and ignores unknown frontmatter, so the same files work in both. Codex CLI and Gemini CLI don't have a rules directory; instead, the install script generates a managed section in their single rules file (`~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`) containing all `alwaysApply: true` rules.

| Rule | Description |
|---|---|
| `thoughts-aware` | Makes the agent aware of the user's thoughts journal (path configurable; see [Customization](#customization)) |
| `web-scraping` | Decision tree and CLI reference for web scraping tasks |

The thoughts journal path is configured by `journal-config.local.mdc`, which is generated from `journal-config.example.mdc` by the install script and gitignored so each user can customize it independently.

### MCP Template

`mcp-template.json` provides a starting point for MCP server configuration. Each IDE looks for MCP config at a different path; the install script prints the right one for your selected IDE(s) in its post-install summary.

## Per-IDE Install Map

| Item | Cursor | Claude Code | Codex CLI | Gemini CLI |
|---|---|---|---|---|
| Skills | symlink `~/.cursor/skills` | symlink `~/.claude/skills` | symlink `~/.codex/skills` | symlink `~/.gemini/skills` |
| Agents | symlink `~/.cursor/agents` | symlink `~/.claude/agents` | (n/a) | (n/a) |
| Rules dir | symlink `~/.cursor/rules` | symlink `~/.claude/rules` | (n/a) | (n/a) |
| Always-applied rules | (loaded from rules dir) | also embedded in `~/.claude/CLAUDE.md` | embedded in `~/.codex/AGENTS.md` | embedded in `~/.gemini/GEMINI.md` |

For IDEs that use a single rules file, the install script writes a managed section bracketed by `<!-- BEGIN agent-config-public -->` / `<!-- END agent-config-public -->`. Existing user content in those files is preserved; re-running the installer updates only the marked section.

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

- **Choose target IDE(s)**: pass `--ide=cursor,claude,codex,gemini` (or any subset) to `install.sh`. Use `--ide=auto` to install for whichever IDEs are already on your machine, or `--ide=all` to install everywhere. Without the flag, the script prompts interactively.
- **Thoughts journal path**: edit the path in `rules/journal-config.local.mdc` (created by `install.sh` from `journal-config.example.mdc`, then symlinked into each IDE's rules directory). To set the path during initial install, pass `--thoughts-dir=/your/path` or set `THOUGHTS_DIR=/your/path`. The local config is gitignored, so personal paths never end up in the repo. If `journal-config.local.mdc` is absent (e.g., you skipped `install.sh`), each skill still names `~/code/thoughts/` as the inline default, so journal-related skills keep working — just without per-user configurability until you create the local config.
- **Add your own skills**: Create `skills/<name>/SKILL.md` and they'll be picked up by every IDE you've installed for (the directory is symlinked, not copied).
- **MCP servers**: Copy `mcp-template.json` to your IDE's MCP config path (`~/.cursor/mcp.json`, `~/.claude/.mcp.json`, `~/.codex/config.toml`, or `~/.gemini/settings.json`) and fill in your endpoints.
- **Rules**: Add `.mdc` files to `rules/` for persistent agent context. Files matching `rules/*.local.mdc` are gitignored — useful for any per-user config you want kept out of the repo. After adding a new always-applied rule, re-run `install.sh` to refresh the managed section in `CLAUDE.md`/`AGENTS.md`/`GEMINI.md`.

## License

MIT
