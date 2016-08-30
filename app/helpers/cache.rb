require 'dalli'

class Nabu

	@@dc = Dalli::Client.new

	def cache(key, ttl: 60, cache: true)
		# immediately return the contents of our block if we're asked not to cache
		if !cache && block_given?
			return yield
		end

		# ttl of 0 is a shortcut for "delete this key".
		if ttl == 0
			return @@dc.delete(key)
		end

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
