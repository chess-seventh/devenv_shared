# devenv_shared

Shared `devenv` modules that other governed repositories import. Nothing here is
built or run on its own — these files are *read* by another repository's devenv
evaluation.

## Where this repository lives

**The fleet's forge is canonical (L598).** `tools/devenv_shared` on the forge
is where this repository is developed and where its branches are cut; the
GitHub repository it came from is a **mirror downstream of it**. Both carry
every branch and tag, at the same objects.

⚠ **So a commit pushed to GitHub is a commit the forge does not have, and the
mirror will overwrite it.** Clone from the forge, on the fleet's own network:

```bash
git clone ssh://forgejo@nixos-02.caracara-palermo.ts.net:2223/tools/devenv_shared.git
```

⚠ **THE MIRROR IS A PUSH MIRROR AND IT IS NOT THIS REPOSITORY'S TO
CONFIGURE.** It is an admin-level setting on the forge carrying a GitHub
credential, so it is set by hand and not by anything here. Until it is live,
GitHub holds whatever it held on the day of the move;
`docs/feature/l598-phase2-tools-forge/measure.md` records what was measured.

⛔ **THIS REPOSITORY HAS NO GATE ON THE FORGE, AND THAT IS NOT AN OMISSION.**
It never had a GitHub Actions workflow either — as this file already says,
nothing here is built or run on its own, so there is nothing for a `push`/
`pull_request` job to check.

## What is in here

| file | what it carries |
|---|---|
| `shared_pkgs.nix` | packages every repo wants (just, treefmt + formatters) |
| `rust_pkgs.nix` | the Rust toolchain and cargo tooling |
| `claude_code.nix` | the shared `claude.code` block |
| `shared_githooks.nix` | a full git-hooks set — **imported by nothing today** |
| `git_hooks.nix` | entirely commented out; evaluates to `{}` |
| `devenv.nix` | this repo's own commit gate (see below) |

## ⚠ The shared hooks have never applied anywhere

`git_hooks.nix` is the file consumers import, and every line of it is commented
out, so it evaluates to `{}`. `shared_githooks.nix` beside it holds the real
block and nothing imports it.

Consumers reach these files through an impure path built from
`builtins.getEnv "HOME"`, filtered by `builtins.pathExists`:

```nix
sharedDirs = builtins.filter builtins.pathExists [
  "${builtins.getEnv "HOME"}/src/claude-src/repos/devenv_shared"
  "${builtins.getEnv "HOME"}/devenv_shared"
];
```

A path that does not exist is dropped **in silence**, so a wrong path removes
every shared module with no error at all. `rusty_cv_creator`'s own comment
records that this already happened: *"the shared git hooks and the shared
`claude.code` block below were never actually applied anywhere."*

Two repositories import it today: `rusty_cv_creator` and `rusty-commit-saver`.
This is routed to Archon as its own lane — a shared-hooks mechanism that is
wired up and has never applied a hook is the same species of defect as the one
L235 closed.

**Do not put the fleet gate behind this mechanism.** A gate that can disappear
without saying so is the failure class the fleet refuses.

## The commit gate

`devenv.nix` here carries four hooks and nothing else: the **fleet gate**, the
checks every repository on the fleet shares (`gitleaks`, `detect-private-key`,
`gitlint`, `commitizen`, and the hygiene fixers).

Before L235 this repository had no `devenv.nix` and no hooks of its own. Its
entire gate was the fleet's global `core.hooksPath` — git found no local value,
resolved the global one, and ran the fleet gate. L235 removed that value,
because it was making `prek` refuse to install eight *other* repositories' own
hooks. Without this file, that removal would have left this repository
completely ungated, in silence.

`hooks/fleet-gate-hook` is a tracked copy of the script the flake packages and
tests. The flake is private, so taking it as an input would put a deploy-key
wall in front of entering this shell on every box.

On a box with no fleet gate installed it says so on every commit and never
blocks:

```
fleet gate: NOT INSTALLED on this box - pre-commit ran this repo's hooks only
```

To see what a commit would be refused for, without making one:

```bash
cfg=$(devenv build git-hooks.configFile | grep -o '/nix/store/[^"]*')
devenv shell -- prek run --all-files -c "$cfg"
```

To skip a single fleet hook here only — `--no-verify` turns the whole gate off,
which is not the same thing:

```bash
git config hooks.fleetGate.skip <hook-id>
git config --unset hooks.fleetGate.skip     # restore it
```

**There is deliberately no toolchain in `devenv.nix`.** No packages, no language
integration, no `enterShell`. Anything added here would make entering *every*
consumer's shell depend on this repository.
