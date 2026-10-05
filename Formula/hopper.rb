require_relative "../custom_download_strategy"

class Hopper < Formula
  desc "nammayatri build network CLI"
  homepage "https://github.com/nammayatri/hopper"
  version "1.6.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/v1.6.0/hopper-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "70382918f03c41c089fc4fbcf15446712c26050b2bc33816636ffe4362f59b6e"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/v1.6.0/hopper-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "7e78372d96b4f53207389c4f6e4f2ae62e9f8f8297465a7c647d93086aad49d3"
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
