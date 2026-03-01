module CacheTestSetup
  def setup
    super

    Rails.cache.clear
  end
end
