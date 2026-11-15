# Design

This tool copies **one branch** from a source Git repository into a target repository. It does not copy every branch, tag, hosting setting, pull request or issue.

The engine:
1. Takes a per-job lock using an atomic directory creation.
2. Fetches source and target into a local bare cache.
3. Compares commit IDs and ancestry.
4. Logs NOOP if identical; pushes only when target is an ancestor of source.
5. Re-reads the target after a push to check the result.
6. Exits with an error on target-ahead or diverged histories.

Empty target repositories can receive a first branch. A nonempty target that lacks the requested branch is rejected to avoid accidental branch creation.

Normal, non-force Git pushes protect against non-fast-forward updates by another writer. Local locks are not distributed across different machines. Scheduling, credentials, alerting and log rotation belong to the operator, not to the sync engine.

Saved jobs are plain text fields created through CLI arguments; they are not sourced as shell commands.