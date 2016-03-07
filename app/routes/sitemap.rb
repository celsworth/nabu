class Nabu

	route 'sitemap' do |r|

		r.get do
			# these @vars are used in templates as well

			@sitemap = CmsPage.published.order(:name)

			# only admin can see private pages
			@sitemap = @sitemap.visible unless user.is_admin?

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
