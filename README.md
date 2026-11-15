# git-mirror-syncer

Portable, one-way Git branch synchronization.

Copies a source branch to a target branch only when the target can fast-forward. Stops on target-ahead or diverged histories. It does not merge or force-push.

The engine is a POSIX shell script. It does not depend on GitHub Actions, Python, or a particular Git hosting provider.

See [README.md](README.md) for usage after the initial import.
