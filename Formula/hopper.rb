require_relative "../custom_download_strategy"

class Hopper < Formula
  desc "nammayatri build network CLI"
  homepage "https://github.com/nammayatri/hopper"
  version "1.8.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/v1.8.0/hopper-darwin-arm64",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "6b01b7a79ceba3c49aa0763783eda73b632d50e20544f7d11314b2e968e59ec9"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/v1.8.0/hopper-linux-amd64",
        using: GitHubPrivateRepositoryReleaseDownloadStrategy
    sha256 "0e01d1c1c8b42ece6a2606784e4048c0c971a77375c605c28db78f1d3c518d4c"
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
