task :boot do
	require File.expand_path 'config/boot', __dir__
end

task :sequel do
	require File.expand_path 'config/database', __dir__
end

desc 'Start Debugger Console'
task :console => :boot do
	# these 3 lines make $rack.get('/') etc available.
	require 'racksh/session'
	rack_app = Rack::Builder.parse_file('config.ru').first
	$rack = Rack::Shell::Session.new(rack_app)
	require 'pry'

	include CDS

	env_color = (RACK_ENV == 'production' ? "\e[31m\e[1m" : "\e[36m\e[1m")
	puts "\nPry #{Pry::VERSION} started in #{env_color}#{RACK_ENV}\e[0m environment\n\n"

	Pry.start
end

# Documentation task
require 'yard'
YARD::Rake::YardocTask.new do |t|
	t.files   = %w(app/**/*.rb lib/**/*.rb config/**/*.rb - README.md TODO.md SRP.md)
	t.options = ['--protected', '--private', '--verbose']
	t.stats_options = ['--list-undoc', '--compact']
end

namespace :db do
	desc 'Load the seed data from db/seeds.rb'
	task :seed => :boot do
		load File.expand_path 'db/seeds.rb', __dir__
	end

	namespace :migrate do
		desc "Perform migration up/down to VERSION"
		task :to, [:version] => :sequel do |t, args|
			version = (args[:version] || ENV['VERSION']).to_s.strip
			raise "No VERSION was provided" if version.empty?
			migrate = File.expand_path 'db/migrate', __dir__
			::Sequel::Migrator.apply(Sequel::Model.db, migrate, version.to_i)
			puts "<= db:migrate:to[#{version}] executed"
		end

		desc "Perform migration up to latest migration available"
		task :up => :sequel do
			migrate = File.expand_path 'db/migrate', __dir__
			::Sequel::Migrator.run Sequel::Model.db, migrate
			puts "<= db:migrate:up executed"
		end

		desc "Perform migration down (erase all data, DANGEROUS)"
		task :down => :sequel do
			migrate = File.expand_path 'db/migrate', __dir__
			puts "5 seconds to abort this data-destroying operation.."
			sleep 5
			::Sequel::Migrator.run Sequel::Model.db, migrate, :target => 0
			puts "<= db:migrate:down executed"
		end
	end

	desc "Perform migration up to latest migration available"
	task :migrate => 'db:migrate:up'

end # }}}

task :seed => 'db:seed'
