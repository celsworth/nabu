began_at = Time.now

RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)
dev = RACK_ENV == 'development'

APP_ROOT = File.expand_path '../../', __FILE__ unless defined?(APP_ROOT)

require 'bundler'
Bundler.setup(:default, RACK_ENV)

require 'cae/logger'
require 'ansi'

# setup the logger before you use it!
Cae::Logger.defaults[:level] = dev ? Logger::DEBUG : Logger::WARN

LOGGER = Cae::Logger.new

LOGGER.debug "bundler done in #{'%.6f' % [ Time.now - began_at ]}s"

require 'better_errors' if dev

require 'rack/unreloader'
Unreloader = Rack::Unreloader.new(reload: dev, logger: dev && LOGGER) do
	WebCMS
end
def reload!() Unreloader.reloader.reload! end

# early prerequisites
%w(lib).each do |path|
	LOGGER.debug "LOAD ".ansi(:yellow, :bold) + path do
		Unreloader.require(path) do |f|
			# some_model.rb -> SomeModel
			File.basename(f).sub(/\.rb\z/, '').split('_').map(&:capitalize).join
		end
	end
end

require 'tilt/haml' # squash tilt warning

[
	'config/database.rb',
	'app/lib',         # generic libraries
	'app/decorators',  # Decorators; additional specific functionality on classes
	'app/presenters',  # Presenters; decorators specifically for display functionality
	'app/models',      # Sequel Models
	'app/policies',    # Policy Objects; read-only filtering logic
	'app/services',    # Service Objects; read/write business logic
	'app/queries',     # Query Objects; complex model operations
	'app/values',      # Value Objects
].each do |path|
	LOGGER.debug "LOAD ".ansi(:yellow, :bold) + path do
		Unreloader.require(path) do |f|
			# some_model.rb -> SomeModel
			File.basename(f).sub(/\.rb\z/, '').split('_').map(&:capitalize).join
		end
	end
end

#DB.dump_schema_cache? File.join APP_ROOT, 'tmp', 'schema.cache'

DB.loggers << Sequel::SourceLogger.new(DB, LOGGER)

LOGGER.debug "config/boot done in %.6fs" % [ Time.now - began_at ]
