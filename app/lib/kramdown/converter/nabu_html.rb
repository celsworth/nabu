require 'kramdown'

module Kramdown
	module Converter
		class NabuHtml < Html

			def convert_a(el, indent)
				res = inner(el, indent)

				# Extract pagename and set a data- attribute I can use in
				# CSS depending on whether the page exists in my db.
				#
				# This benefits from using relative links in markdown, ie
				# I just link to projects.nabu literally as
				# [Nabu](projects.nabu), making the href comparison simple.
				el.attr['data-page-exists'] =
					CmsPage.page_cache.include? el.attr['href']

				format_as_span_html(el.type, el.attr, res)
			end
		end
	end
end
