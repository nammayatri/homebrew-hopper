require_relative "../custom_download_strategy"

class Hopper < Formula
  desc "nammayatri build network CLI"
  homepage "https://github.com/nammayatri/hopper"
  version "1.3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/v1.3.0/hopper-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "4afa3221dcbcd2b0ec5f3ddab7df7d039205dd6f9a852954bfbf50d132a62db7"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/v1.3.0/hopper-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "33a422c34b91be34c608160f09cee9f6d77920cac97892148ff64f1322ccb088"
  end

  def install
    if OS.mac?
      bin.install "hopper-darwin-arm64" => "hopper"
    else
      bin.install "hopper-linux-amd64" => "hopper"
    end
  end

  test do
    assert_match "hopper", shell_output("#{bin}/hopper 2>&1", 1)
  end
end
