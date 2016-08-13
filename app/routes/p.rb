class Nabu

	route 'p' do |r|
		r.is 'preview' do
			r.halt 403 unless user.is_admin? # we're not a free md renderer.
			response.headers['Content-Type'] = 'text/javascript'
			cpv = CmsPageVersion.new(content: r.params['content'])
			"$('.md-preview').html(#{cpv.render_html.to_json});"
		end

		r.on :pagename do |pagename|

			@page = CmsPage[name: pagename] || CmsPage.new(name: pagename)

			@pv = if user.is_admin? && pv = r.params['pv']
							# facility to view old versions for admin
							CmsPageVersion[page: @page, id: pv] or r.halt 404
						else
							# don't 404 for admins, we may want to create the page
								@page&.latest_visible(user) or (r.halt 404 unless user.is_admin?)
						end

			# For now I intentionally haven't done a #visible check here;
			# if someone knows the name of a page then I probably gave them
			# it so they can view it. See how that logic goes..

			r.is do
				# caching only active for guests; not admin
				# using r.path as the cache key is for ngx_http_memcached_module
				# (even without using that, this doubles Nabu's throughput)
				cache(r.path, cache_if: ->(){ !user.is_admin? }) do
				render 'p/view'
			end
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

					# update visible status
					@page.update(visible: r.params['visible'])

					# update tags
					@page.set_tags(r.params['tags'].split(','))

					# clear the page name cache,
					# it will be refilled on the next hit
					CmsPage.page_name_cache.clear

					r.redirect "/p/#{@page.name}"
				end

				r.get do
					render 'p/edit'
				end
			end
		end


	end

end
