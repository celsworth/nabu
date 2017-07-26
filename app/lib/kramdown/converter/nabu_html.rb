# frozen_string_literal: true

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
        # I just link to projects.nabu as [Nabu](projects.nabu),
        # making the href comparison simple.
        href = el.attr['href']
        # skip this for any remote links, or page anchor links
        unless href[0..1] == '//' || href[0..3] == 'http' || href[0] == '#'
          el.attr['data-page-exists'] =
            CmsPage.page_name_cache.include? href
        end

        format_as_span_html(el.type, el.attr, res)
      end

      def convert_p(el, indent)
        if el.options[:transparent]
          inner(el, indent)
        elsif !el.children.nil? && el.children.count == 1 && el.children.first.type == :img
          # paragraph only contains an image; treat it as a figure instead.
          convert_figure(el, el.children.first, indent)
        else
          format_as_block_html(el.type, el.attr, inner(el, indent), indent)
        end
      end

      def convert_figure(parent, el, indent)
        "#{' ' * indent}<figure #{html_attributes(parent.attr)}><img#{html_attributes(el.attr)} />#{(el.attr['title'] ? "<figcaption>#{el.attr['title']}</figcaption>" : '')}</figure>\n"
      end
    end
  end
end
