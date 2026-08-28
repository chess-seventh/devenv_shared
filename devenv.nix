# devenv_shared devenv — the fleet gate, and deliberately nothing else.
#
# WHY THIS FILE EXISTS AT ALL (L235, 2026-08-28). This repository had no
# `devenv.nix` and no git hooks of its own. Its entire commit gate was the
# GLOBAL `core.hooksPath` that `hooks_everywhere.nix` set: git found no local
# value, resolved the global one, and ran the fleet gate. That is a fallback, and
# L235 removed it — the same global value was making `prek` REFUSE to install
# eight other repositories' own hooks, so those repositories were running no gate
# at all while this one was quietly fine.
#
# Without this file, removing the value would have taken this repository from
# fully gated to no gate whatsoever, in silence. It holds shared devenv modules
# that every governed repository imports, so an unreviewed change here reaches
# further than one in most of them.
#
# ⚠ SCOPE IS THE GATE, NOT A DEV SHELL. There is no toolchain, no language
# integration and no `enterShell` here on purpose: nothing in this repository is
# built or run, it is read by other repositories' devenv evaluations. Adding a
# package here would make entering those shells depend on this one.
{ pkgs, ... }:
let
  # L235 - THE FLEET GATE, as four ordinary hooks of this repository's own
  # (D-115).
  #
  # Built through writeShellApplication so the script is shellchecked at build
  # time and the entries name a store path rather than a working-tree file.
  fleetGateHook = "${
    pkgs.writeShellApplication {
      name = "fleet-gate-hook";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.git
      ];
      text = builtins.readFile ./hooks/fleet-gate-hook;
    }
  }/bin/fleet-gate-hook";
in
{
  git-hooks.hooks = {
    fleet-gate = {
      enable = true;
      name = "fleet gate";
      stages = [ "pre-commit" ];
      entry = "${fleetGateHook} pre-commit";
      language = "system";
      pass_filenames = false;
      always_run = true;
    };

    # pass_filenames, because git hands commit-msg the message file and the
    # fleet gate's gitlint and commitizen read it. Getting this wrong lints the
    # wrong thing while still exiting 0.
    fleet-gate-commit-msg = {
      enable = true;
      name = "fleet gate (message)";
      stages = [ "commit-msg" ];
      entry = "${fleetGateHook} commit-msg";
      language = "system";
      pass_filenames = true;
      always_run = true;
    };

    fleet-gate-pre-push = {
      enable = true;
      name = "fleet gate (push)";
      stages = [ "pre-push" ];
      entry = "${fleetGateHook} pre-push";
      language = "system";
      pass_filenames = false;
      always_run = true;
    };

    # The commit diary is hooks_everywhere.nix's post-commit hook - NOT
    # pkgs/git-commit-gate, which ships pre-commit and commit-msg only. On a box
    # with no fleet gate there is no diary, and the entry says so per commit.
    fleet-gate-post-commit = {
      enable = true;
      name = "fleet gate (diary)";
      stages = [ "post-commit" ];
      entry = "${fleetGateHook} post-commit";
      language = "system";
      pass_filenames = false;
      always_run = true;
    };
  };
}
