# { config, pkgs, lib, inputs, ... }: {
#   git-hooks.hooks = {
#     rusty-commit-saver = {
#       enable = true;
#       name = "🦀 Rusty Commit Saver";
#       stages = [ "post-commit" ];
#       after = [
#         "commitizen"
#         "gitlint"
#         "gptcommit"
#       ];
#       entry = "${
#         inputs.rusty-commit-saver.packages.${pkgs.stdenv.hostPlatform.system}.default
#       }/bin/rusty-commit-saver";
#       pass_filenames = false;
#       language = "system";
#       always_run = true;
#     };
#   };
# }
{}
