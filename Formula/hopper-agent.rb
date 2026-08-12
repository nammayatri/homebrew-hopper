require_relative "../custom_download_strategy"

class HopperAgent < Formula
  desc "NodeBackproxy agent — runs on provisioned fleet nodes, not developer machines"
  homepage "https://github.com/nammayatri/hopper"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.0/internal-agent-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "4121cc47b9f5ba3e18b42299a6b738c8a28fb5928bb925d44637b2043b4ce30b"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.0/internal-agent-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "0637dcd1bcc9dd1861c41ad14cf9431601b63938237ebcfb908e2a54ecab661b"
  end

  def install
    if OS.mac?
      bin.install "internal-agent-darwin-arm64" => "internal-agent"
    else
      bin.install "internal-agent-linux-amd64" => "internal-agent"
    end
  end

  test do
    # No CLI parsing at all — it's a plain server binary that requires
    # SD_URL/SD_TAILNET_IP to be set and panics fast (exit 101, Rust's
    # default panic code) otherwise. That's the only thing safe to assert
    # without actually starting a long-running server during `brew test`.
    output = shell_output("#{bin}/internal-agent 2>&1", 101)
    assert_match "SD_URL must be set", output
  end
end
