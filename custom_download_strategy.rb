require "download_strategy"
require "net/http"
require "uri"

class GitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
  require "utils/formatter"

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
    candidates = []
    env_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    candidates << [env_token, "HOMEBREW_GITHUB_API_TOKEN"] if env_token && !env_token.empty?
    cached = load_cached_token
    candidates << [cached, "saved GitHub token"] if cached && !cached.empty?

    candidates.each do |token, source|
      @github_token = token
      if github_token_valid?
        ohai "Using #{source}" if source == "saved GitHub token"
        return
      end
      opoo "#{source} was rejected by GitHub (expired, revoked or no access to #{@owner}/#{@repo})"
      clear_cached_token if source == "saved GitHub token"
    end

    3.times do
      @github_token = prompt_for_token
      raise CurlDownloadStrategyError, "GitHub token is required to access private repository." if @github_token.nil? || @github_token.empty?
      if github_token_valid?
        save_token(@github_token)
        ohai "Token saved to #{token_cache_path} for future use."
        return
      end
      opoo "That token cannot access #{@owner}/#{@repo}. Needs repo (or Contents: read) access, authorized for the organization."
    end
    raise CurlDownloadStrategyError, "No valid GitHub token provided."
  end

  # Bypasses Homebrew's own internal `GitHub` API client entirely —
  # that class resolves credentials from Homebrew's own environment
  # (HOMEBREW_GITHUB_API_TOKEN, `gh` CLI auth, etc.), completely
  # independent of @github_token above. On a machine where that's never
  # been configured (any fresh Linux box, for instance), this used to
  # 401/404 as an anonymous request regardless of how correct the token
  # just typed into the prompt was — a real, confirmed bug (proven via a
  # direct `curl` with the same token succeeding where this failed).
  # Plain authenticated HTTP with the actual token instead, no reliance
  # on any of Homebrew's own ambient GitHub auth state.
  def github_api_get(path)
    uri = URI("https://api.github.com#{path}")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "token #{@github_token}"
    req["User-Agent"] = "Homebrew"
    req["Accept"] = "application/vnd.github+json"
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
  end

  def github_token_valid?
    github_api_get("/repos/#{@owner}/#{@repo}").is_a?(Net::HTTPSuccess)
  rescue StandardError
    false
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

  # Same fix as github_token_valid? above — was calling
  # Homebrew's own internal GitHub client (GitHub.get_release) with no
  # way to pass @github_token in, so it silently depended on Homebrew's
  # own ambient credential state instead of the token actually entered.
  def fetch_release_metadata
    require "json"
    res = github_api_get("/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}")
    unless res.is_a?(Net::HTTPSuccess)
      raise CurlDownloadStrategyError, "Could not fetch release #{@tag} for #{@owner}/#{@repo}: #{res.code} #{res.message}"
    end
    JSON.parse(res.body)
  end
end
