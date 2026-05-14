{ config, pkgs, lib, inputs, ... }: {
  packages = with pkgs; [ 
    bacon
    curl
    gh
    git
    gnused
    jq
  ];

  scripts = {
    devhelp = {
      description = ''
        Show helper commands for devenv.nix
      '';
      exec = ''
        echo
        echo 💡 Helper scripts to ease development process:
        echo
        ${pkgs.gnused}/bin/sed -e 's| |••|g' -e 's|=| |' <<EOF | ${pkgs.util-linuxMinimal}/bin/column -t | ${pkgs.gnused}/bin/sed -e 's|^|• |' -e 's|••| |g'
        ${lib.generators.toKeyValue { } (lib.mapAttrs (name: value: value.description) config.scripts)}
        EOF
        echo
      '';
    };

    ghpr_create = {
      description = "Create GH PR with first commit as title, rest as body";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Check we're not on master
        CURRENT_BRANCH=$(git branch --show-current)
        if [ "$CURRENT_BRANCH" = "master" ]; then
          echo "❌ Cannot create PR from master branch"
          exit 1
        fi

        # Get all commits not in master
        COMMIT_COUNT=$(git rev-list --count master..HEAD)

        if [ "$COMMIT_COUNT" -eq 0 ]; then
          echo "❌ No commits to create PR from"
          exit 1
        fi

        # First commit (oldest) becomes the title
        PR_TITLE=$(git log master..HEAD --reverse --pretty=format:'%s' | head -1)

        echo "📝 Creating PR with title:"
        echo "   $PR_TITLE"
        echo ""
        echo "🚀 Pushing branch: $CURRENT_BRANCH"

        # Push current branch
        git push -u origin "$CURRENT_BRANCH"

        # Create PR
        gh pr create \
          --title "$PR_TITLE" \
          --body "" \
          --base master

        echo ""
        echo "✅ PR created successfully!"
      '';
    };
  };
}

