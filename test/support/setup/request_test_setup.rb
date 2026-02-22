# frozen_string_literal: true

module RequestTestSetup
  MODERN_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

  def setup
    super

    host! "#{AppUtil.webapp_host}:#{AppUtil.webapp_port}"
  end

  def request_headers
    { "User-Agent" => MODERN_USER_AGENT }
  end
end
