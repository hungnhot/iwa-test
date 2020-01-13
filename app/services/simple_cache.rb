# frozen_string_literal: true

module SimpleCache
  private
  def read_cache
    Rails.cache.fetch(cache_key)
  end

  def write_cache data, options = {expires_in: 3.days}
    Rails.cache.write(cache_key, data, options)
  end

  def cache_key
    raise NotImplementedError
  end
end
