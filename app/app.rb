require 'roda'

class WebCMS < Roda

	use Cae::Logger::Middleware
	use BetterErrors::Middleware if defined? BetterErrors

	use Rack::Session::Cookie, key: 'webcms.session', secret: 'RAAAAH'


	plugin :assets, {
		path: "#{__dir__}/assets",
		css: {
			app: %w( app.scss )
		},
		js: {
			app: %w( app.js )
		}
	}
	plugin :csrf
	plugin :delegate
	request_delegate :logger # expose rack.logger as logger
	plugin :environments
	plugin :halt
	plugin :multi_route
	plugin :padrino_render,
		engine: 'haml',
		views:  'app/templates', layout: 'layouts/application'
	plugin :static, %w(/dist /favicon.ico /icons),
		header_rules: [ [:all, {'Cache-Control' => 'private, max-age=3600'}] ]
	plugin :status_handler

	configure do
		Haml::Options.defaults[:ugly]   = production?
		Haml::Options.defaults[:format] = :html5
	end
	configure :development do
		if defined? BetterErrors
			BetterErrors::Middleware.allow_ip! '192.168.0.0/16'
			BetterErrors::Middleware.allow_ip! '10.0.0.0/8'
			BetterErrors.application_root = APP_ROOT
		else
			# no logger() exposed here?
			Cae::Logger.warn "BetterErrors not loaded"
		end
	end

	status_handler 404 do
		render 'errors/404'
	end

	route do |r|
		r.assets

		r.multi_route

		r.root do
			render 'index'
		end
	end


end

Unreloader.require("#{__dir__}/helpers"){}
Unreloader.record_split_class __FILE__, "#{__dir__}/helpers"

Unreloader.require("#{__dir__}/routes"){}
Unreloader.record_split_class __FILE__, "#{__dir__}/routes"
