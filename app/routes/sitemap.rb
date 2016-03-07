class Nabu

	route 'sitemap' do |r|

		r.get do
			# these @vars are used in templates as well

			@sitemap = CmsPage.published.order(:name)

			# guests can only see visible pages
			@sitemap = @sitemap.visible unless user.logged_in?

			if (@tag = r.params['tag']) && (t = Tag[name: @tag])
				# tag filtering, if set.
				@sitemap = @sitemap.where(tags: t)
			elsif @search = r.params['search']
				# search query, if set.
				@sitemap = @sitemap.search(@search)
			end

			render 'sitemap'
		end

	end

end
