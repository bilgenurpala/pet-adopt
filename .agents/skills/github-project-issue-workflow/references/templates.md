# Workflow Templates

## Implementation brief

```markdown
# Issue #N — Title

## Goal

## Context

## Ownership
- Owned paths:
- Protected paths:

## In scope

## Out of scope

## Acceptance criteria

## Validation
- Automated:
- Manual:

## Git workflow
- Base branch:
- Feature branch:
- Commit convention:

## Delivery
- Required artifacts:
- Issue link mode: Closes / Refs / Part of
```

## Pull request body

```markdown
Closes #N

## Changes

## Scope
- Changed owned paths only
- Protected contributor files were not modified

## Validation
- [ ] Targeted automated tests
- [ ] Static analysis or lint
- [ ] Manual critical flow
- [ ] CI green

## Unverified
- None
```

Replace `Closes #N` with `Refs #N` or `Part of #N` when the PR is only one part
of the issue. Never leave a passed test checked when it did not run.

## Closure decision

| State | Issue action |
|---|---|
| All mandatory items complete and CI green | Close |
| Required artifact or integration remains | Keep open |
| Only explicitly optional work remains | Close with a note |
| PR completes only part of the issue | Use `Refs` or `Part of` |
| PR linked the wrong issue | Correct links and issue states |
