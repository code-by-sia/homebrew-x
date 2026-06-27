# typed: false
# frozen_string_literal: true

# Homebrew formula for the Ξ (Xi) programming language toolchain.
#
# This file is the source of truth for the `code-by-sia/homebrew-xi` tap; the
# release workflow regenerates the version/url/sha256 lines via
# `scripts/update-formula.sh` and pushes the result to the tap repo. See
# packaging/homebrew/README.md for the one-time tap setup.
class Xi < Formula
  desc "The Ξ (Xi) programming language toolchain (compiler + REPL)"
  homepage "https://github.com/code-by-sia/xi"
  version "0.0.84"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.84/xi-v0.0.84-macos-arm64.tar.gz"
      sha256 "55152e1e8c138ca8072b14b4b05cd5e82976bdd2cdeb3b71a9a9fa7f8e06fcd3"
    end
    on_intel do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.84/xi-v0.0.84-macos-x86_64.tar.gz"
      sha256 "f3e5b5fc85e4ef351c35a5d4dcb1923d7bd75b26b3237a4442f12ee565995652"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.84/xi-v0.0.84-linux-arm64.tar.gz"
      sha256 "b30fba173b3ebd6346d72c3eeb0c05c0e17fe43fdf0656def3060e4a9dcc808a"
    end
    on_intel do
      url "https://github.com/code-by-sia/xi/releases/download/v0.0.84/xi-v0.0.84-linux-x86_64.tar.gz"
      sha256 "0998cb3404b7e5c8b4d2b66e87696c4a42def0fa65ae926217d7a30f197e5dba"
    end
  end

  def install
    # The tarball expands to a single top-level dir (Homebrew has already cd'd
    # into it). Stash the bundle under libexec and write absolute-path wrappers
    # so xc/xi find the runtime and stdlib regardless of how bin is symlinked.
    libexec.install Dir["*"]

    (bin/"xc").write <<~SH
      #!/bin/sh
      export XC_RUNTIME="${XC_RUNTIME:-#{libexec}/runtime}"
      export XC_STD="${XC_STD:-#{libexec}}"
      exec "#{libexec}/libexec/xc" "$@"
    SH

    (bin/"xi").write <<~SH
      #!/bin/sh
      export XC_RUNTIME="${XC_RUNTIME:-#{libexec}/runtime}"
      export XC_STD="${XC_STD:-#{libexec}}"
      export XC="${XC:-#{bin}/xc}"
      exec "#{libexec}/libexec/xi" "$@"
    SH

    chmod 0755, bin/"xc"
    chmod 0755, bin/"xi"
  end

  def caveats
    <<~EOS
      xc compiles Xi to C and invokes a C compiler to produce native binaries,
      so a working `cc` (clang/gcc) must be on your PATH.
    EOS
  end

  test do
    (testpath/"hello.xi").write <<~XI
      import "std/log.xi"
      async entry (logger: Logger) main(args: String[]) {
          logger.info("brew ok")
      }
      module App {}
    XI
    assert_match "brew ok", shell_output("#{bin}/xi hello.xi")
  end
end
