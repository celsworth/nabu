# app setup contained in here for re-use in rspec
require File.expand_path '../config/boot', __FILE__

LOGGER.debug "LOAD ".ansi(:yellow, :bold) + 'app/app.rb' do
	Unreloader.require('app/app.rb'){|f| 'Nabu' }
end

run Unreloader

