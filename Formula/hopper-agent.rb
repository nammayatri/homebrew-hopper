require_relative "../custom_download_strategy"

class HopperAgent < Formula
  desc "NodeBackproxy agent — runs on provisioned fleet nodes, not developer machines"
  homepage "https://github.com/nammayatri/hopper"
  version "0.1.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.2/internal-agent-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "7ae9bf17677c0233f51d0894c3034ad2aaa1901bc99e734093c4737f8d581a97"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.2/internal-agent-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "93aac1197e56655c930af3192c9a787ba3757b95108ed8c9fe4c19853210a035"
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
