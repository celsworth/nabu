class Nabu

	route 'sitemap' do |r|

		r.get do
			@sitemap = CmsPage.published.order(:name)
			render 'sitemap'
		end

	end

end
