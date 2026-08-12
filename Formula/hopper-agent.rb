require_relative "../custom_download_strategy"

class HopperAgent < Formula
  desc "NodeBackproxy agent — runs on provisioned fleet nodes, not developer machines"
  homepage "https://github.com/nammayatri/hopper"
  version "0.1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.1/internal-agent-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "4b9ebe8fed2be2990dcef0f7f2299ffa9315967a113f9d34f55c5bde59c92086"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.1/internal-agent-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "14dbb46c7108879f146d5605e5aed09cc763535a10c3ae33d332a2ba5997f920"
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
