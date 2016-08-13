require 'dalli'

class Nabu

	EMPTY_OPTS = {}.freeze

	@@dc = Dalli::Client.new

	def cache(key, opts = EMPTY_OPTS, cache_if: nil)
		# if cache_if is a callable proc which returns false,
		# immediately return the contents of our block, don't cache anything.
		return yield if cache_if && !cache_if.call

		ttl = opts.fetch(:ttl, 60)

		# ttl of 0 is a shortcut for "delete this key".
		return @@dc.delete(key) if ttl == 0

		# return the value if the cache finds it
		if val = @@dc.get(key)
			return val
		end

		# otherwise, set the cache value
		@@dc.set(key, val, ttl) if val = yield

		# and return that value
		val
	end

end
