require 'kramdown'

class CmsPageVersion < Sequel::Model
	many_to_one :page, class: :CmsPage, key: :cms_page_id
	many_to_one :user

	def render_html
		sh_opts = {
			css: :style,
			default_lang: 'ruby',
			line_numbers: false,
			line_number_anchors: false,
			bold_every: 99999,
			tab_width: 4,
		}
		# can add pre/post-processing here later
		kramdown = Kramdown::Document.new(content,
										  toc_levels: 2..6,
										  syntax_highlighter_opts: sh_opts)

		# #to_nabu_html calls Kramdown::Converter::NabuHtml which is
		# a subclass of Html, containing some of my markdown overrides.
		return kramdown.to_nabu_html
	end

	def render_text
		# FIXME: Be a little less stupid here.
		html = render_html.gsub(/<[^>]+>/, ' ')
	end

	def validate
		super

		validates_not_null [:user_id, :content]
		validates_unique [:cms_page_id, :version], only_if_modified: true
	end

	def published?
		!published_at.nil?
	end

	def publish!
		unless published?
			db.transaction do
				return if page.lock!.published_id == self.id
				update(published_at: Time.new)
				page.update(published_id: self.id)
			end
		end
	end

	def unpublish!
		if published?
			db.transaction do
				update(published_at: nil)
				reload
				if page.lock!.published_id == self.id
					latest = page.published_dataset.first
					latest &&= latest.id
					page.update(published_id: latest)
				end
			end
		end
	end
end
