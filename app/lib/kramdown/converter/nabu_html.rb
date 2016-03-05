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
				href = el.attr['href']
				# skip this for any remote links.
				unless href[0..1] == '//' || href[0..3] == 'http'
					el.attr['data-page-exists'] =
						CmsPage.page_name_cache.include? href
				end

				format_as_span_html(el.type, el.attr, res)
			end
		end
	end
end
