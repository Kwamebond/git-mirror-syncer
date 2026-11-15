# Operator runbook

## Inspect jobs and logs

```sh
sh bin/git-sync list
sh bin/git-sync run --all --dry-run
tail -n 50 "$HOME/.local/state/git-sync/logs/JOB.log"
```

| Exit | Meaning | Action |
| --- | --- | --- |
| 0 | Success, no change or dry run | None |
| 1 | Batch contains failures | Inspect job logs |
| 2 | Invalid CLI or saved job | Review parameters |
| 3 | Target ahead or branch missing | Review target |
| 4 | Diverged histories | Reconcile by review or merge |
| 5 | Git, authentication, IO or verification failure | Inspect failed stage |
| 6 | Existing lock | Inspect process and stale state |

## Divergence

Fetch both branches into a regular worktree and compare:

```sh
git fetch upstream main
git fetch origin main
git log --oneline --left-right --graph origin/main...upstream/main
```

Resolve differences through the normal collaboration process. Never force-push simply to clear a collision alert.

## Stale locks

A crash can leave a lock directory behind. Inspect the PID file in `~/.local/state/git-sync/locks/JOB.lock/pid`, verify that no worker is using the directory, and only then remove the stale lock. Local directory locks do not coordinate workers on multiple hosts.

## Scheduling

The CLI runs once and exits. Use cron, systemd, Jenkins, or any other approved scheduler. Ensure noninteractive Git authentication is available. Avoid embedding tokens in remote URLs: Git errors may print those URLs into logs. Rotate logs separately.