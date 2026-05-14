{ config, pkgs, lib, inputs, ... }: {
  packages = with pkgs; [ 
    cargo-nextest
    cargo-shear
    cargo-llvm-cov
    cargo-watch
    # rustup

    cargo-deny
    cargo-edit # cargo add, cargo rm, cargo upgrade
    cargo-expand # cargo expand for macro debugging
    cargo-outdated # check for outdated dependencies
    cargo-audit # security audit
    cargo-deny # dependency management
    cargo-release # release management
    cargo-cross # cross-compilation
    cargo-machete # find unused dependencies
    cargo-update # update installed binaries
  ];

  languages = {
    rust = {
      enable = true;
      channel = "nightly";
      components = [
        "rustc"
        "cargo"
        "clippy"
        "rustfmt"
        "rust-analyzer"
        "rust-std"
        "llvm-tools-preview"
      ];
    };
  };

  git-hooks.hooks = {
    clippy = {
      name = "✂️ Clippy";
      enable = true;
      entry = "cargo clippy --all-targets -- -W clippy::pedantic -A clippy::must-use-candidate";
      language = "system";
      settings.allFeatures = true;
      extraPackages = [ pkgs.openssl ];
      stages = [ "pre-commit" ];
      pass_filenames = false;
    };
  };


  scripts = {
    cclippy = {
      description = ''
        Run clippy
      '';
      exec = ''
        cargo clippy --all-targets -- -W clippy::pedantic -A clippy::missing_errors_doc -A clippy::must_use_candidate -A clippy::module_name_repetitions -A clippy::doc_markdown -A clippy::missing_panics_doc
      '';
    };

    watch-clippy = {
      description = "Watch and re-run tests on file changes";
      exec = ''
        bacon clippy
      '';
    };
    # cargo watch -x 'clippy --all-targets -- -D warnings' -x 'llvm-cov --html nextest --no-fail-fast'

    watch-coverage = {
      description = "Watch and re-run nextest on file changes";
      exec = ''
        bacon coverage
      '';
    };
    # cargo watch -x 'nextest run --no-fail-fast --all-targets'

    watch-check = {
      description = "Watch and run quick checks (clippy only)";
      exec = ''
        cargo watch -x 'clippy --all-targets -- -D warnings'
      '';
    };

    build-project = {
      description = "Build the Rust project";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "🔨 Building Rust project..."
        cargo build
      '';
    };

    build-release = {
      description = "Build the Rust project in release mode";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "🚀 Building Rust project (release mode)..."
        cargo build --release
      '';
    };

    test-cargo = {
      description = "Run tests with cargo test";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "🧪 Running tests..."
        cargo test
      '';
    };

    test-coverage = {
      description = "Run tests with coverage (matches CI exactly)";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "📊 Running tests with coverage (CI-equivalent)..."

        # Clean previous coverage data
        cargo llvm-cov clean --workspace

        # Run tests with nextest (same as CI)
        cargo llvm-cov --no-report nextest --no-fail-fast

        # Generate lcov report (same as CI)
        cargo llvm-cov report --lcov --output-path lcov.info

        # Also generate human-readable summary
        echo ""
        echo "📈 Coverage Summary:"
        cargo llvm-cov report

        echo ""
        echo "✅ Coverage report saved to: lcov.info"
      '';
    };

    test-coverage-html = {
      description = "Run tests with coverage and open HTML report";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "📊 Running tests with coverage (HTML)..."
        cargo llvm-cov clean --workspace
        cargo llvm-cov --no-report nextest --no-fail-fast
        cargo llvm-cov report --html
        cargo llvm-cov report
        echo ""
        echo "📂 HTML report: target/llvm-cov/html/index.html"
      '';
    };

    lint = {
      description = "Run Clippy linter";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "🔍 Running Clippy linter..."
        cargo clippy --all-targets --all-features -- -D warnings
      '';
    };

    format = {
      description = "Format code with rustfmt";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "🎨 Formatting code..."
        treefmt
      '';
    };

    check-code = {
      description = "Check code without building";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "✅ Checking code..."
        cargo check
      '';
    };

    audit-cargo = {
      description = "Security audit with cargo audit";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "🔒 Running security audit..."
        cargo audit
      '';
    };

    outdated = {
      description = "Check for outdated dependencies";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "📦 Checking for outdated dependencies..."
        cargo outdated
      '';
    };

    clean = {
      description = "Clean build artifacts";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "🧹 Cleaning build artifacts..."
        cargo clean
      '';
    };

    deps = {
      description = "Show dependency tree";
      exec = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "📦 Dependency tree:"
        cargo tree
      '';
    };

  };


}

