# L598 — devenv_shared is canonical on the forge under tools/

One of the four repositories this lane moves. Every number below is command
output, not a number anybody typed; an item marked NOT YET MEASURED is exactly
that, never inferred.

## Must-prove 1 — the forge carries every branch and tag GitHub has

⛔ **NOT YET MEASURED — blocked on the push-create, which Claude Code's
auto-mode classifier refused as this session's own action ("Data
Exfiltration").** Franci runs the push himself; this section is filled in once
it lands.

BEFORE, measured 2026-09-27 with `git ls-remote --refs`/`--tags` against
`origin` (GitHub):

```text
afc91c9ab8f82cfaffe73569665056a63b6d2391  refs/heads/feat/L235
acd21046a170e5d037189aa3d6c0cad012b2bf6d  refs/heads/feat/L598
acd21046a170e5d037189aa3d6c0cad012b2bf6d  refs/heads/main
```

⚠ **NO TAGS ON EITHER SIDE.** `git ls-remote --tags` answers empty, so the
tag half of this item is satisfied vacuously once the push lands. Recorded
rather than left implied, because a vacuous pass and a real one read the same
in a summary.

⚠ **`feat/L598` IS THIS LANE'S OWN CLAIM BRANCH**, taken after the above, so it
appears in any later forge listing and is not a discrepancy.

The command Franci runs, from
`/home/seventh/src/claude-worktrees/devenv_shared/L598`:

```bash
git push forge 'refs/remotes/origin/*:refs/heads/*'
```

AFTER: ⛔ NOT YET MEASURED. To close this item: `git ls-remote --refs forge`
against `origin`'s list above with `comm -23`, expecting nothing printed.

## Must-prove 2 — no file under .github/workflows after the lane

✅ **Satisfied vacuously.** This repository has never had a `.github/`
directory — no workflow existed before this lane and none is added by it.

## Must-prove 3 — a push to the forge creates a task on a seat that exists, or the repo declares no workflow at all

✅ **This repository declares no workflow at all**, so this item is met by the
second clause. README.md's "Where this repository lives" section says so:
nothing here is built or run on its own — these are `devenv` modules another
repository's evaluation reads — so there is nothing for a `push`/
`pull_request` job to check, and no `.forgejo/workflows/gate.yaml` is added.

## Must-prove 4 — no push mirror is created, and the README says why

✅ **No mirror configured or requested by this lane.** README.md's new
"Where this repository lives" section names the forge as canonical, gives the
clone line, and says the mirror is an admin-level forge setting outside this
repository's own configuration — same wording as the sibling migrations
(L562/564/566/567/568 and this lane's own rusty-ntfy/rusty-commit-lister
halves).
