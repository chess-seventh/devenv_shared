# Shared Claude Code (devenv) config — imported by per-repo devenv.nix.
# Repo-agnostic: hooks write NO logs into the working tree, so they never churn
# git or block branch switches. Drop this file in ~/devenv_shared and import it.
{ pkgs, ... }:
{
  claude.code = {
    enable = true;
    hooks = {
      # Block edits to secret-bearing files before they happen.
      protect-secrets = {
        enable = true;
        name = "Protect sensitive files";
        hookType = "PreToolUse";
        matcher = "^(Edit|MultiEdit|Write)$";
        command = ''
          file_path=$(${pkgs.jq}/bin/jq -r '.file_path // empty')
          case "$file_path" in
          *.env | *.env.* | *.secret | *.pem | *.key | */secrets/*)
            echo "Refusing to edit sensitive file: $file_path" >&2
            exit 1
            ;;
          esac
        '';
      };

      # Finish marker written to a per-user state dir (NOT the repo) so it never
      # touches git. Works verbatim in any repo.
      track-completion = {
        enable = true;
        name = "Track when Claude finishes";
        hookType = "Stop";
        command = ''
          dir="''${XDG_STATE_HOME:-$HOME/.local/state}/claude/$(basename "$PWD")"
          mkdir -p "$dir"
          printf '%s finished\n' "$(date -Iseconds)" >>"$dir/sessions.log"
        '';
      };
    };
  };
}
