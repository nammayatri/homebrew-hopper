require_relative "../custom_download_strategy"

class HopperAgent < Formula
  desc "NodeBackproxy agent — runs on provisioned fleet nodes, not developer machines"
  homepage "https://github.com/nammayatri/hopper"
  version "0.1.4"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.4/internal-agent-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "f636f7d4b678345d160950f307727908d6e95ce73ecb744cde5032c755df4010"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/internal-agent-v0.1.4/internal-agent-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "dd57a525a40555afa179a8020177396210d8517bc96d8cfeeef13cd5f330306a"
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
