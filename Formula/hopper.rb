require_relative "../custom_download_strategy"

class Hopper < Formula
  desc "nammayatri build network CLI"
  homepage "https://github.com/nammayatri/hopper"
  version "1.5.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/v1.5.0/hopper-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "2355f95a6caf9698188cb56472563d97ca8499b1614fb6b91dfb7058b7255ba7"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/v1.5.0/hopper-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "8fa83ef61ceef5a3ac59f90e6d35b08ef2a345430c386787fb08d2a5d8a240af"
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
