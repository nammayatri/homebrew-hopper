require "download_strategy"

class GitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
  require "utils/formatter"
  require "utils/github"

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  def parse_url_pattern
    unless match = url.match(%r{https://github.com/([^/]+)/([^/]+)/(\S+)})
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Repository."
    end
    _, @owner, @repo, @filepath = *match
  end

  def download_url
    "https://#{@github_token}@github.com/#{@owner}/#{@repo}/#{@filepath}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    curl_download download_url, to: temporary_path, timeout: timeout
  end

  def token_cache_path
    Pathname.new(Dir.home) / ".config" / "homebrew-hopper" / "github_token"
  end

  def load_cached_token
    return nil unless token_cache_path.exist?
    token_cache_path.read.strip
  end

  def save_token(token)
    token_cache_path.dirname.mkpath
    token_cache_path.write(token)
    token_cache_path.chmod(0o600)
  end

  def clear_cached_token
    token_cache_path.delete if token_cache_path.exist?
  end

  def prompt_for_token
    require "io/console"
    ohai "GitHub Personal Access Token required to download #{@owner}/#{@repo}"
    $stderr.print "Enter your GitHub token (input hidden): "
    token = $stdin.noecho(&:gets)&.chomp
    $stderr.puts
    token
  end

  def set_github_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]

    unless @github_token
      @github_token = load_cached_token
      if @github_token
        ohai "Using saved GitHub token from #{token_cache_path}"
        begin
          validate_github_repository_access!
          return
        rescue CurlDownloadStrategyError
          opoo "Saved token is invalid or expired, clearing it."
          clear_cached_token
          @github_token = nil
        end
      end
    end

    unless @github_token
      @github_token = prompt_for_token
      raise CurlDownloadStrategyError, "GitHub token is required to access private repository." if @github_token.nil? || @github_token.empty?
      validate_github_repository_access!
      save_token(@github_token)
      ohai "Token saved to #{token_cache_path} for future use."
      return
    end

    validate_github_repository_access!
  end

  def validate_github_repository_access!
    GitHub.repository(@owner, @repo)
  rescue GitHub::HTTPNotFoundError
    message = <<~EOS
      HOMEBREW_GITHUB_API_TOKEN can not access the repository: #{@owner}/#{@repo}
      This token may not have permission to access the repository or the url of formula may be incorrect.
    EOS
    raise CurlDownloadStrategyError, message
  end
end

class GitHubPrivateRepositoryReleaseDownloadStrategy < GitHubPrivateRepositoryDownloadStrategy
  def initialize(url, name, version, **meta)
    super
  end

  def parse_url_pattern
    url_pattern = %r{https://github.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    unless @url =~ url_pattern
      raise CurlDownloadStrategyError, "Invalid url pattern for GitHub Release."
    end
    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def download_url
    "https://#{@github_token}@api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    curl_download download_url, "--header", "Accept: application/octet-stream", to: temporary_path, timeout: timeout
  end

  def asset_id
    @asset_id ||= resolve_asset_id
  end

  def resolve_asset_id
    release_metadata = fetch_release_metadata
    assets = release_metadata["assets"].select { |a| a["name"] == @filename }
    raise CurlDownloadStrategyError, "Asset file not found." if assets.empty?
    assets.first["id"]
  end

  def fetch_release_metadata
    GitHub.get_release(@owner, @repo, @tag)
  end
end
