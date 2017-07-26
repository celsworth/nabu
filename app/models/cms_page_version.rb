# frozen_string_literal: true

require 'kramdown'
require 'coderay_bash' # add bash support to coderay

class CmsPageVersion < Sequel::Model
  many_to_one :page, class: :CmsPage, key: :cms_page_id
  many_to_one :user

  def render_html
    sh_opts = {
      css: :class,
      default_lang: 'ruby',
      line_numbers: false,
      line_number_anchors: false,
      bold_every: 99_999,
      tab_width: 4
    }
    # can add pre/post-processing here later
    kramdown = Kramdown::Document.new(content,
                                      input: 'GFM',
                                      toc_levels: 2..4,
                                      syntax_highlighter: 'coderay',
                                      syntax_highlighter_opts: sh_opts)

    # #to_nabu_html calls Kramdown::Converter::NabuHtml which is
    # a subclass of Html, containing some of my markdown overrides.
    kramdown.to_nabu_html
  end

  def render_text
    # FIXME: Be a little less stupid here.
    html = render_html.gsub(/<[^>]+>/, ' ')
  end

  def validate
    super

    validates_not_null %i[user_id content]
    validates_unique %i[cms_page_id version], only_if_modified: true
  end

  def published?
    !published_at.nil?
  end

  def publish!
    unless published?
      db.transaction do
        return if page.lock!.published_id == id
        update(published_at: Time.new)
        page.update(published_id: id)
      end
    end
  end

  def unpublish!
    if published?
      db.transaction do
        update(published_at: nil)
        reload
        if page.lock!.published_id == id
          latest = page.published_dataset.first
          latest &&= latest.id
          page.update(published_id: latest)
        end
      end
    end
  end
end
