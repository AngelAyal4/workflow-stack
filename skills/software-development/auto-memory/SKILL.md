---
name: auto-memory
description: "Auto-save session summaries and decisions at session end."
version: 1.0.0
author: Angel Ayala, Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [memory, session, summary, context, persistence]
    related_skills: [session-librarian, obsidian]
---

# Auto-Memory

Automatically capture decisions, discoveries, and context at the end of significant work sessions. The user has limited working memory — this skill is the external RAM.

## When to Use

- A coding session produced meaningful decisions or discoveries
- The user says "ya terminé" or signals a session end
- Before switching contexts to an unrelated task
- A bug fix or architectural decision was made

## What to Capture

| Category | Examples |
|---|---|
| **Decisions** | Why approach X was chosen over Y, trade-offs accepted |
| **Discoveries** | Root cause of a bug, unexpected behavior, project conventions |
| **Pending work** | What's left to do, known issues, TODOs |
| **Context** | File paths, commit SHAs, config changes, environment details |

## Session Summary Format

Write to `~/.hermes/sessions/<date>-<topic>.md`:

```markdown
# Session: <topic>
Date: <ISO date>
Duration: ~<X> min

## Decisions
- <decision>: <rationale>

## Discoveries
- <what was learned>

## Files Changed
- `<path>`: <what changed>

## Pending
- <what remains>

## Next Session Context
<what the next session needs to know to continue>
```

## Memory Tool Entries

For durable facts that survive across sessions, use the `memory` tool:

- **User preferences**: workflow choices, tool conventions
- **Project facts**: architecture decisions, deployment details
- **Recurring patterns**: error types, solutions that worked

Keep entries compact. Memory is injected every turn — bloated entries waste context.

## Pitfalls

- Do not capture trivial sessions (one-line fixes, simple questions).
- Do not duplicate what's already in git commits or Obsidian notes.
- Do not save task progress or completed-work logs — use `session_search` for that.
- Do not invent facts to fill the template — if nothing notable happened, skip it.

## Verification

- Session summary exists on disk with the correct date.
- Memory entries are compact and factual.
- The user can read the summary and continue without re-explaining context.
