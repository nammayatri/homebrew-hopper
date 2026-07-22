require_relative "../custom_download_strategy"

class Hopper < Formula
  desc "nammayatri build network CLI"
  homepage "https://github.com/nammayatri/hopper"
  version "1.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/v1.2.0/hopper-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "90820f75616347f73eeccff9c36cbbda61a2cf3dce3311164987573722f3d9e6"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/v1.2.0/hopper-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "f9984a05398ba15699def3c849e4b48aa84cc0ee6d3a5c1b6e8e66f2f1396865"
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
