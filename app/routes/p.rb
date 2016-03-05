class Nabu

	route 'p' do |r|
		r.is 'preview' do
			response.headers['Content-Type'] = 'text/javascript'
			cpv = CmsPageVersion.new(content: r.params['content'])
			"$('.md-preview').html(#{cpv.render_html.to_json});"
		end

		r.on :pagename do |pagename|

			# TODO: caching
			@page = CmsPage[type: 'page', name: pagename] || CmsPage.new(type: 'page', name: pagename)
			@pv = @page&.latest_visible(user)

			r.halt 404 unless @pv or user.is_admin?

			r.is do
				render 'p/view'
			end

			r.is 'edit' do
				r.halt 403 unless user.is_admin?

				r.post do
					@page.save if @page.new?
					pv = @page.add_version(user: user,
										   content: r.params['content'],
										   display_title: r.params['display_title'],
										   version: @pv ? @pv.version + 1 : 1
										  )
					# all pages are published for now, drafts not implemented
					pv.publish!

					# update tags
					@page.set_tags(r.params['tags'].split(','))

					# clear the page cache, it will be refilled on the next hit
					CmsPage.page_cache.clear

					r.redirect "/p/#{@page.name}"
				end

				r.get do
					render 'p/edit'
				end
			end
		end


	end

end
