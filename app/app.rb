require 'roda'
require 'autoprefixer-rails'

class Nabu < Roda

	use Cae::Logger::Middleware
	use BetterErrors::Middleware if defined? BetterErrors

	use Rack::Session::Cookie, key: 'nabu.session', secret: 'RAAAAH'

	plugin :assets, {
		path: "#{__dir__}/assets", gzip: true,
		css: %w( normalize.css app.scss coderay.css ),
		css_compressor: :yui, # default, but being explicit..
		js: {
			jquery: 'jquery-3.1.0.min.js',
			sta: 'smart-time-ago-0.1.5.js',
		},
		js_compressor: :yui,

		postprocessor: ->(file, type, content) do
			type == :css ? AutoprefixerRails.process(content).css : content
		end
	}
	plugin :caching
	plugin :csrf
	plugin :delegate
	request_delegate :logger # expose rack.logger as logger
	plugin :environments
	plugin :halt
	plugin :multi_route
	plugin :padrino_render,
		engine: 'haml',
		views:  'app/templates', layout: 'layouts/application'
	plugin :public
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

	compile_assets if production?

	route do |r|
		r.assets
		r.public

		r.multi_route

		# Apachetop README links here
		r.on 'projects/apachetop' do
			r.redirect '/p/projects.apachetop', 301
		end

		r.root do
			r.redirect '/p/home'
		end
	end


end

Unreloader.require("#{__dir__}/helpers"){}
Unreloader.record_split_class __FILE__, "#{__dir__}/helpers"

Unreloader.require("#{__dir__}/routes"){}
Unreloader.record_split_class __FILE__, "#{__dir__}/routes"
