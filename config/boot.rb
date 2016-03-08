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
	Nabu
end
def reload!() Unreloader.reloader.reload! end

require 'tilt/haml' # squash tilt warning

# lib and app/lib laid out Gem-style; sub-directories are nested classes/modules
[
	'lib',             # early prerequisites, monkey-patching etc.
	'app/lib',         # generic libraries
].each do |path|
	Unreloader.require(path) do |f|
		# kramdown/converter/nabu_html.rb -> Kramdown::Converter::NabuHtml
		f.sub(File.expand_path(path), ''). # remove path prefix
			sub(/^\//, ''). # remove leading /
			sub(/\.rb\z/, '').split('/').map(&:capitalize).join('::').
			gsub(/_(.)/){ $1.upcase } # first letter capitalisation
	end
end

[
	'config/database.rb',
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
