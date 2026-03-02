class ValidateSiteUrl
  # Path: one or more segments, then optional trailing slash + zero or more safe chars.
  # Query: optional ? followed by safe chars (key=value&key2=value2).
  PATTERN = %r{
    \A
      (?<protocol>
        https?
      )
      ://
      (?<host>
        ([a-z0-9] [a-z0-9-]{,49} \.){,4}
         [a-z0-9] [a-z0-9-]{,49} \.
         [a-z0-9] [a-z0-9-]{,49}
      )
      (?<path>
        (/[a-z0-9\-._~]+)*
        (/[a-z0-9\-._~]*)?
      )
      (?<query>
        (\?[a-z0-9\-._~=%&]*)?
      )
    \z
  }xi

  RESERVED_NAMES = %w[
    corp
    domain
    example
    home
    host
    internal
    intranet
    invalid
    lan
    local
    localdomain
    localhost
    onion
    private
    test
  ]

  attr_reader :site_url, :errors

  def initialize(site_url)
    @site_url = site_url.to_s
    @errors = [:not_yet_validated]
  end

  def valid?
    errors.clear

    validate_format
    validate_path_safety
    validate_site_url_domain

    errors.empty?
  end

  def invalid?
    !valid?
  end

  private

  def validate_format
    return if demo_site_url?

    unless site_url.match?(PATTERN)
      @errors << :format_invalid
    end
  end

  def validate_path_safety
    return if demo_site_url?
    return if errors.include?(:format_invalid)

    path = site_url.match(PATTERN)&.named_captures&.fetch("path", nil).to_s
    return if path.empty?

    if path.include?("..") || path.include?("//")
      @errors << :format_invalid
    end
  end

  def validate_site_url_domain
    return if demo_site_url?

    if match_reserved_domain?
      @errors << :domain_not_supported
    end
  end

  def match_reserved_domain?
    match_data = site_url.match(PATTERN)

    match_data.present? && host_has_reserved_name?(match_data[:host])
  end

  def host_has_reserved_name?(host)
    parts = host.split(".")

    parts.last(3).any? { |part| RESERVED_NAMES.include?(part) }
  end

  def demo_site_url?
    Rails.env.development? && site_url == ENV.fetch("DEMO_SITE_URL", "")
  end
end
