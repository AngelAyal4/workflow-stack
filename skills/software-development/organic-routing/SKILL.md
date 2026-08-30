---
name: organic-routing
description: "Route coding tasks by complexity: direct, delegated, or SDD."
version: 1.0.0
author: Angel Ayala, Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [routing, workflow, delegation, sdd]
    related_skills: [sdd-feature-delivery-review, test-driven-development]
---

# Organic Routing

Route every task through the smallest useful implementation route. Do not ask the user to choose — decide based on file count and ambiguity.

## When to Use

- Starting any coding task beyond a one-line fix
- The user asks for a feature, fix, research, or refactor
- You are about to delegate work to a sub-agent

## Routing Rules

| Route | Condition | Action |
|---|---|---|
| **Direct inline** | 1-3 files affected, no research needed, design is clear | Do it yourself. No delegation. |
| **Delegated direct** | 4+ files, broad research needed, or 2+ non-trivial files to write | Delegate to one focused sub-agent. |
| **Optional SDD** | Substantial ambiguity, durable spec/design would reduce uncertainty | Propose SDD. Do not force it. |

## Decision Process

1. Estimate how many files you need to read to understand the task.
2. Estimate how many files you need to modify.
3. Check if the design is clear or if there are unresolved decisions.
4. Apply the table above. Default to the lighter route.

## Direct Inline

- Read the files.
- Make the change.
- Verify with tests/build/lint.
- Report what changed.

## Delegated Direct

- Use `delegate_task` with a self-contained goal.
- Pass the exact file paths and context the sub-agent needs.
- The sub-agent must report back with concrete evidence (diff, test results, file paths).
- Verify the sub-agent's output before reporting success to the user.

## Optional SDD

- When the task is large or ambiguous, propose SDD: "This is a substantial feature. Want me to use SDD to plan it first?"
- If the user accepts, follow the SDD workflow (explore → propose → spec → design → implement → verify).
- If the user declines, use Delegated Direct with a reduced scope.

## Pitfalls

- Do not use SDD for small tasks — it's overkill.
- Do not delegate when you already know the answer — just do it.
- Do not ask "should I use SDD?" for trivial work — the answer is always no.
- The file count is about the *current action*, not the whole project.

## Verification

- The chosen route matches the task complexity.
- Direct: you did the work yourself.
- Delegated: the sub-agent returned verifiable evidence.
- SDD: the user explicitly accepted the proposal.
