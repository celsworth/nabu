class Nabu

	route 'sitemap' do |r|

		r.get do
			@sitemap = CmsPage.published.order(:name)

			# tag filtering, if set. @tag is used in sitemap.haml as well.
			if (@tag = r.params['tag']) && (t = Tag[name: @tag])
				@sitemap = @sitemap.where(tags: t)
			end

			render 'sitemap'
		end

	end

end
