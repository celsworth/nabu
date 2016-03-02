class Nabu

	route 'account' do |r|
		r.on 'login' do
			r.post do
				if (user = User[email: r.params['email']]) && user.authenticate_password(r.params['password'])
					session[:user_id] = user.id
					r.redirect r.params['referer']
				end
				render 'account/login' # TODO: display login error
			end

			r.get do
				r.redirect '/' if user.logged_in?
				render 'account/login'
			end
		end

		r.on 'logout' do
			session.destroy
			r.redirect r.referer
		end

	end

end
