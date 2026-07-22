---
name: github-project-issue-workflow
description: Convert GitHub Project issues or pasted issue briefs into scoped, ownership-safe implementation workflows, validation plans, commits, pull request descriptions, and closure audits. Use when Codex needs to start, execute, review, hand off, or close work tracked in GitHub Issues or Projects, especially in collaborative repositories with file ownership boundaries and Definition of Done checklists.
---

# GitHub Project Issue Workflow

Turn one tracked issue into a traceable delivery workflow without expanding its
scope or changing another contributor's files.

## Gather the issue

1. Obtain the repository, issue number, title, body, acceptance criteria and
   current project status.
2. Prefer an available GitHub connector, API or CLI for live data. If live
   access is unavailable, ask for the issue text or screenshots.
3. Never guess an issue number, ownership boundary or required deliverable.
4. Treat optional checklist items as non-blocking only when the issue labels
   them explicitly as optional.

## Normalize the work

Extract and present these fields before implementation:

- Goal and expected user-visible outcome
- In-scope and out-of-scope work
- Owned files and protected contributor files
- Dependencies and integration prerequisites
- Acceptance criteria and Definition of Done
- Automated and manual validation
- Required delivery artifacts

Read [references/templates.md](references/templates.md) when producing an issue
prompt, implementation brief, pull request body or closure audit.

## Inspect the repository

1. Read repository instructions and inspect Git status before editing.
2. Preserve unrelated and uncommitted work.
3. Compare the current branch with the latest target branch.
4. Create a branch that follows repository conventions, normally
   `<type>/issue-<number>-<slug>`.
5. Stop before editing when a required change crosses a protected ownership
   boundary. Record it as an integration prerequisite or request permission.

## Plan and implement

1. Map each acceptance criterion to a code, test or documentation change.
2. Keep the smallest implementation that satisfies the issue.
3. Add tests only for the owned scope unless the issue authorizes broader work.
4. Make reversible changes and preserve existing behavior outside the scope.
5. Use conventional commit messages and omit AI signatures or trailers.

## Validate

1. Run the narrowest relevant tests, then broader checks when available.
2. Compare changed paths against the target branch and ownership boundary.
3. Run whitespace and diff checks.
4. State any command that could not run and the exact reason.
5. Do not claim E2E, CI or manual validation that has not actually completed.

## Deliver

1. Generate a concise PR title and a body covering changes, scope and tests.
2. Recheck the issue number against the source issue before linking it.
3. Use `Closes #N` only when the PR completes every required item.
4. Use `Refs #N` or `Part of #N` for partial work, prerequisites or follow-ups.
5. Confirm the final PR diff contains no unrelated contributor files.

## Audit closure

Keep the issue open when a required checklist item, integration prerequisite,
CI result or delivery artifact remains. Close it only after every mandatory
item is complete. If a merged PR referenced the wrong issue, edit the PR body,
reopen the incorrectly closed issue and close the correct issue manually when
needed.
