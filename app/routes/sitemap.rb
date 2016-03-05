class Nabu

	route 'sitemap' do |r|

		r.get do
			@sitemap = CmsPage.published.order(:name)

			# the @vars set below are used in templates as well

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
