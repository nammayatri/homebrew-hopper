require_relative "../custom_download_strategy"

class HopperAgent < Formula
  desc "NodeBackproxy agent — runs on provisioned fleet nodes, not developer machines"
  homepage "https://github.com/nammayatri/hopper"
  version "0.1.3"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.3/internal-agent-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "8dc386bc072a89f11a0eb9100b2394956e1618f42832e7603a1f6f62fd6a6d45"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.3/internal-agent-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "8a5241ac26674f9f7abd9957c9b905c1acb1a45dd454107ed225ebef4c6cd517"
  end

  def install
    if OS.mac?
      bin.install "internal-agent-darwin-arm64" => "internal-agent"
    else
      bin.install "internal-agent-linux-amd64" => "internal-agent"
    end
  end

  test do
    # Only `install` is a real subcommand; invoked with no args at all it's
    # still a plain server binary that requires SD_URL/SD_TAILNET_IP to be
    # set and panics fast (exit 101, Rust's default panic code) otherwise.
    # That's the only thing safe to assert without actually starting a
    # long-running server during `brew test`.
    output = shell_output("#{bin}/internal-agent 2>&1", 101)
    assert_match "SD_URL must be set", output
  end
end
