# :nodoc:
module Sequel

	# Log the source line a Sequel query is issued from.
	class SourceLogger
		def initialize(db, logger)
			@db = db
			@logger = logger
		end

		# :nodoc:
		def method_missing(meth, *params)
			if c = caller(1).find { |c| c.match(/webcms/) }
				m = c.match(/^(.+?):(\d+)(?::in `(.*)')?/)
				f = m[1].gsub(/.*app\//, '').gsub(/.*cds\//, '')
				l = '[%s:%s] ' % [ f.ansi(:magenta, :bold), m[2].ansi(:magenta, :bold) ]
			end
			@logger.send meth, [l, *params]
		end
	end
end
