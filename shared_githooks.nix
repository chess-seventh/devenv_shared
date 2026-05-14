{ config, pkgs, lib, inputs, ... }: {
  git-hooks.hooks = {
    rusty-commit-saver = {
      enable = true;
      name = "🦀 Rusty Commit Saver";
      stages = [ "post-commit" ];
      after = [
        "commitizen"
        "gitlint"
        "gptcommit"
      ];
      entry = "${
        inputs.rusty-commit-saver.packages.${pkgs.stdenv.hostPlatform.system}.default
      }/bin/rusty-commit-saver";
      pass_filenames = false;
      language = "system";
      always_run = true;
    };

    check-merge-conflicts = {
      name = "🔒 Check Merge Conflicts";
      enable = true;
      stages = [ "pre-commit" ];
    };

    detect-aws-credentials = {
      name = "💭 Detect AWS Credentials";
      enable = true;
      stages = [ "pre-commit" ];
    };

    detect-private-keys = {
      name = "🔑 Detect Private Keys";
      enable = true;
      stages = [ "pre-commit" ];
    };

    end-of-file-fixer = {
      name = "🔚 End of File Fixer";
      enable = true;
      stages = [ "pre-commit" ];
    };

    mixed-line-endings = {
      name = "🔀 Mixed Line Endings";
      enable = true;
      stages = [ "pre-commit" ];
    };

    trim-trailing-whitespace = {
      name = "✨ Trim Trailing Whitespace";
      enable = true;
      stages = [ "pre-commit" ];
    };

    shellcheck = {
      name = "✨ Shell Check";
      enable = true;
      stages = [ "pre-commit" ];
      excludes = [
        "^.envrc$"
        "^.direnv/.*"
      ];
    };

    mdsh = {
      enable = true;
      name = "✨ MDSH";
      stages = [ "pre-commit" ];
    };

    treefmt = {
      name = "🌲 TreeFMT";
      enable = true;
      settings.formatters = [
        pkgs.nixfmt
        pkgs.deadnix
        pkgs.yamlfmt
        pkgs.rustfmt
        pkgs.toml-sort
      ];
      stages = [ "pre-commit" ];
    };

    # clippy = {
    #   name = "✂️ Clippy";
    #   enable = true;
    #   entry = "cargo clippy --all-targets -- -W clippy::pedantic -A clippy::must-use-candidate";
    #   language = "system";
    #   settings.allFeatures = true;
    #   extraPackages = [ pkgs.openssl ];
    #   stages = [ "pre-commit" ];
    #   pass_filenames = false;
    # };

    commitizen = {
      name = "✨ Commitizen";
      enable = true;
      stages = [ "post-commit" ];
    };

    gptcommit = {
      name = "🤖 GPT Commit";
      enable = true;
    };

    gitlint = {
      name = "✨ GitLint";
      enable = true;
      after = [ "gptcommit" ];
    };

    markdownlint = {
      name = "✨ MarkdownLint";
      enable = true;
      stages = [ "pre-commit" ];
      excludes = [ "CHANGELOG.md" ];
      settings.configuration = {
        MD033 = false;
        MD013 = {
          line_length = 120;
          tables = false;
        };
        MD041 = false;
      };
    };

    pre-commit-shear = {
      name = "✨ Cargo Dependency Check";
      enable = true;
      # this is a simple shell hook
      entry = ''
        echo "Running cargo-shear pre-commit check..."
        if ! command -v cargo-shear >/dev/null 2>&1; then
          echo "cargo-shear not installed. Run: cargo install cargo-shear --locked"
          exit 1
        fi

        # Only run if there are staged changes in Cargo.toml or Cargo.lock
        if git diff --cached --name-only | grep -Eq '^Cargo\.toml$|^Cargo\.lock$'; then
          cargo shear
        else
          echo "No dependency files changed, skipping cargo-shear."
        fi
      '';
      language = "system";
      stages = [ "pre-commit" ];
    };
  };
}

