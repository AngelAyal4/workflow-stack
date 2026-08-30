---
name: sdd-workflow
description: "Use Spec-Driven Development for large or ambiguous features."
version: 1.0.0
author: Angel Ayala, Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [sdd, planning, architecture, spec, review]
    related_skills: [sdd-feature-delivery-review, organic-routing, requesting-code-review]
---

# SDD Workflow

Spec-Driven Development for substantial features. Use when a task is too ambiguous or large to implement directly. SDD creates durable artifacts that reduce uncertainty before code is written.

## When to Use

- Feature affects 5+ files or multiple subsystems
- Architecture decisions have trade-offs that need exploration
- The user explicitly says "use SDD" or "hazlo con sdd"
- Previous attempts failed due to unclear requirements

## Phases

### 1. Explore

**Goal**: Understand the codebase area affected by the feature.

- Search for relevant files, patterns, and conventions
- Identify integration points and constraints
- Produce a concise findings document (files, patterns, risks)

**Output**: Exploration report with file paths, relevant code patterns, and open questions.

### 2. Propose

**Goal**: Present a concrete implementation approach.

- Describe the recommended approach with trade-offs
- Identify alternatives considered and why they were rejected
- Scope what's included and what's explicitly out of scope

**Output**: Proposal document. The user must approve before proceeding to Spec.

### 3. Spec

**Goal**: Define the contract — what will be built and how success is measured.

- Functional requirements (bullet list)
- Acceptance criteria (testable conditions)
- Data model changes, API contracts, UI behavior
- Edge cases and error states

**Output**: Spec document. User approves before Design.

### 4. Design

**Goal**: Define the technical implementation.

- Architecture: modules, components, data flow
- File-level changes (create/modify/delete)
- Dependencies and integration points
- Testing strategy

**Output**: Design document with file plan and test plan.

### 5. Implement

**Goal**: Build the feature according to the design.

- Follow the file plan from Design
- Write tests before or alongside implementation
- Verify after each file group (build, lint, test)

**Output**: Implemented code, all gates passing.

### 6. Verify

**Goal**: Prove the implementation meets the spec.

- Every acceptance criterion from Spec has evidence
- Tests pass, build succeeds, lint clean
- Edge cases handled

**Output**: Verification report with test results and evidence.

## Delegation Model

Each phase can run as a separate `delegate_task` with a self-contained goal:

- `sdd-explore`: Phase 1 only
- `sdd-propose`: Phase 2 only (requires explore output)
- `sdd-spec`: Phase 3 only (requires proposal approval)
- `sdd-design`: Phase 4 only (requires spec approval)
- `sdd-apply`: Phase 5 only (requires design approval)
- `sdd-verify`: Phase 6 only (requires implementation)

The orchestrator (you) passes the exact artifact paths from the previous phase.

## Artifact Persistence

Save each phase output to keep context across sessions:

```
.hermes/plans/<project>/<feature>/
├── explore.md
├── proposal.md
├── spec.md
├── design.md
└── verify.md
```

## Pitfalls

- Do not skip phases — each one reduces uncertainty for the next
- Do not generate artifacts the user hasn't seen — present and get approval
- Do not let a sub-agent work without the previous phase's output
- Do not use SDD for small, well-understood tasks — direct is faster
- Do not archive incomplete work — if a phase has open questions, keep working it

## Verification

- Every phase has a concrete output file or artifact
- The user explicitly approved each transition
- Final verify phase reports all acceptance criteria with evidence
- Tests pass and build succeeds
