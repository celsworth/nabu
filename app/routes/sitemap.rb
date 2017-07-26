# frozen_string_literal: true

class Nabu
  route 'sitemap' do |r|
    r.get do
      # these @vars are used in templates as well

      @sitemap = CmsPage.published.order(:name)

      # only admin can see private pages
      @sitemap = @sitemap.visible unless user.is_admin?

      if tags = r.params['tags']
        # tag filtering, if set. find pages with all tags
        @tags = Tag.where(name: Array(tags)).order(:name)
        @tags.all { |tag| @sitemap = @sitemap.where(tags: tag) }
      end
      if @search = r.params['search']
        # search query, if set.
        @sitemap = @sitemap.search(@search)
      end

      render 'sitemap'
    end
  end
end
