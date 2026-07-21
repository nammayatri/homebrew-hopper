class Hopper < Formula
  desc "nammayatri build network CLI"
  homepage "https://github.com/nammayatri/hopper"
  version "1.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nammayatri/hopper/releases/download/v1.1.0/hopper-darwin-arm64"
      sha256 "76d80fcf461b89513a525ff2a9a2b28e5f32a1b1dfdaaa5367c424306bea50a9"
    end
  end

  on_linux do
    url "https://github.com/nammayatri/hopper/releases/download/v1.1.0/hopper-linux-amd64"
    sha256 "ef545e1c2f13f4b564f7a3f2da9c4075e0c0209241d8918112969bcbeb139b96"
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
