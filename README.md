# git-mirror-syncer

Portable, one-way Git branch synchronization using POSIX shell and Git. **Fast-forward only.** The tool never force-pushes or automatically merges conflicting histories.

This is a branch-copy utility, not a full Git hosting mirror. It doesn't copy issues, pull requests, tags, repository settings, or every branch. Scheduling is external; no GitHub Actions or Python dependency.

## One-off run

```sh
sh bin/git-sync run \
  --source git@github.com:team/project.git \
  --target git@github.com:me/project.git \
  --source-branch main --target-branch main --dry-run
```

Remove `--dry-run` only after inspecting the proposed change. The source branch defaults to the remote's advertised HEAD. The target branch defaults to the source branch.

## Reuse remotes from an existing clone

Works with normal and bare Git repositories:

```sh
sh bin/git-sync add --name devops \
  --repo "$HOME/Documents/repos/collab-project-mirror" \
  --source-remote upstream --target-remote origin

sh bin/git-sync list
sh bin/git-sync run --job devops --dry-run
sh bin/git-sync run --job devops
sh bin/git-sync run --all
```

Or add a job from URLs without a clone:

```sh
sh bin/git-sync add --name other \
  --source git@github.com:org/source.git \
  --target git@gitlab.com:me/target.git \
  --source-branch develop --target-branch stable
```

Use `--branch main` to set both branch names. Use `--config-dir` and `--state-dir` to override paths. Run `sh bin/git-sync --help` for help.

## State

| Files | Default |
| --- | --- |
| Saved jobs | `~/.config/git-sync/jobs/` |
| Bare Git caches | `~/.local/state/git-sync/cache/` |
| Per-job logs | `~/.local/state/git-sync/logs/` |
| Local locks | `~/.local/state/git-sync/locks/` |

Exit codes: `0` success/no-op/dry-run; `1` batch failure; `2` invalid input; `3` destination ahead or branch missing; `4` divergence; `5` Git/IO failure; `6` lock held.

## Tests

```sh
sh -n bin/git-sync
sh tests/test-sync.sh
```

Tests use temporary local Git repositories; no network access is required.

See [operator runbook](docs/operations.md), [design notes](docs/design.md), and [comment style](docs/style.md).