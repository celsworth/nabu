# frozen_string_literal: true

require 'dalli'

class Nabu
  @@dc = Dalli::Client.new

  def cache(key, ttl: 60, cache: true)
    # immediately return the contents of our block if we're asked not to cache
    return yield if !cache && block_given?

    # ttl of 0 is a shortcut for "delete this key".
    return @@dc.delete(key) if ttl == 0

    # return the value if the cache finds it
    if val = @@dc.get(key)
      return val
    end

    # if there's no block, it was just querying the cache, not setting it
    return nil unless block_given?

    # set the cache value
    val = yield
    @@dc.set(key, val, ttl)

    # and return that value
    val
  end
end
