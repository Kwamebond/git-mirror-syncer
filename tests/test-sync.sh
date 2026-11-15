#!/bin/sh
# Integration tests run entirely against temporary local Git repositories.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tool=$root/bin/git-sync
tmp=$HOME/git-sync-test-$$
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' 0
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
run() { sh "$tool" "$@" --config-dir "$tmp/config" --state-dir "$tmp/state"; }
sha() { git --git-dir="$1" rev-parse refs/heads/main; }

git init --bare -q "$tmp/source.git"
git init --bare -q "$tmp/target.git"
git init -q "$tmp/work"
git -C "$tmp/work" config user.name Test
git -C "$tmp/work" config user.email test@example.invalid
git -C "$tmp/work" checkout -qb main
printf 'one\n' > "$tmp/work/README"
git -C "$tmp/work" add README
git -C "$tmp/work" commit -qm initial
git -C "$tmp/work" remote add upstream "$tmp/source.git"
git -C "$tmp/work" remote add origin "$tmp/target.git"
git -C "$tmp/work" push -q upstream main
git -C "$tmp/work" push -q origin main
git --git-dir="$tmp/source.git" symbolic-ref HEAD refs/heads/main

run add --name test --repo "$tmp/work" --source-remote upstream --target-remote origin
run run --job test
grep -q NOOP "$tmp/state/logs/test.log" || fail 'NOOP not logged'

printf 'two\n' >> "$tmp/work/README"
git -C "$tmp/work" commit -qam update
git -C "$tmp/work" push -q upstream main
before=$(sha "$tmp/target.git")
run run --job test --dry-run
[ "$(sha "$tmp/target.git")" = "$before" ] || fail 'dry-run changed target'
run run --job test
[ "$(sha "$tmp/target.git")" = "$(sha "$tmp/source.git")" ] || fail 'fast-forward failed'
run run --job test
grep -q NOOP "$tmp/state/logs/test.log" || fail 'repeat sync not a NOOP'

printf 'target\n' > "$tmp/work/TARGET"
git -C "$tmp/work" add TARGET
git -C "$tmp/work" commit -qm target-only
git -C "$tmp/work" push -q origin main
if run run --job test >/dev/null 2>&1; then
    fail 'target-ahead was accepted'
else
    [ "$?" -eq 3 ] || fail 'target-ahead exit code'
fi

git -C "$tmp/work" reset -q --hard "$(sha "$tmp/source.git")"
printf 'source\n' > "$tmp/work/SOURCE"
git -C "$tmp/work" add SOURCE
git -C "$tmp/work" commit -qm source-only
git -C "$tmp/work" push -q upstream main
if run run --job test >/dev/null 2>&1; then
    fail 'divergent histories were accepted'
else
    [ "$?" -eq 4 ] || fail 'divergence exit code'
fi

git init --bare -q "$tmp/empty.git"
run add --name empty --source "$tmp/source.git" --target "$tmp/empty.git" --branch main
if run run --all >/dev/null 2>&1; then fail 'batch failure was ignored'; fi
[ "$(sha "$tmp/empty.git")" = "$(sha "$tmp/source.git")" ] || fail 'empty target not initialized'

mkdir -p "$tmp/state/locks/held.lock"
run add --name held --source "$tmp/source.git" --target "$tmp/target.git" --branch main
if run run --job held >/dev/null 2>&1; then fail 'held lock ignored'; else
    [ "$?" -eq 6 ] || fail 'lock exit code'
fi

printf '%s\n' 'PASS: no-op, dry-run, fast-forward, target-ahead, divergence, batch isolation, empty target, lock'
