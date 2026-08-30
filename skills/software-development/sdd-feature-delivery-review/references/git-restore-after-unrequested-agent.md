# Restoring a local checkout after unrequested agent changes

Use this reference only when the user explicitly authorizes replacing the local working tree
with the repository's remote source of truth. It is not a normal cleanup procedure.

## Verified recovery sequence

```bash
# 1. Inspect and refresh remote
 git status --short
 git log -5 --oneline --decorate
 git remote -v
 git fetch origin
 git status -sb
 git log --oneline --left-right HEAD...origin/main
```

If `git fetch origin` fails, distinguish the states clearly:

- `origin/main` is the last locally cached remote-tracking ref;
- it is not proof of the current GitHub branch;
- do not claim a live remote sync until authentication/network is repaired.

## Preserve before deletion

```bash
stamp=$(date +%Y%m%d-%H%M%S)
git diff --binary > /tmp/<repo>-unrequested-$stamp.patch
git ls-files --others --exclude-standard -z \
  | tar --null --create --gzip \
      --file=/tmp/<repo>-unrequested-$stamp.tar.gz \
      --files-from=-
```

Do not archive `.env*`, credentials, or ignored secret material. The patch and archive are
for audit/recovery only; do not silently reapply them.

## Destructive restore

Only after the user's explicit instruction to discard local changes:

```bash
git reset --hard origin/main
git clean -fd
git status -sb
git log -1 --oneline --decorate
git rev-parse HEAD
git rev-parse origin/main
```

Use selective cleanup instead of `git clean -fd` if the user did not authorize deletion of
all untracked files. Never push or make a new commit merely because the reset completed.

## Reporting contract

Report all of the following:

- exact restored SHA;
- whether `git fetch origin` succeeded;
- if it failed, the cached-ref limitation and authentication blocker;
- backup paths for the discarded patch/untracked archive;
- final `git status -sb` result;
- whether any push or commit was intentionally not performed.

This pattern was validated after a terminal coding agent changed tracked config, deleted an
API route, and added untracked scripts/tests/prompts without user authorization. The safe
outcome was a clean restore to the cached stable commit with the rejected work preserved
outside the repository for audit.
