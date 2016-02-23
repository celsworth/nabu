require 'digest/sha2'
require 'bcrypt'

class User < Sequel::Model

	def logged_in?
		id
	end

	def guest?
		!logged_in?
	end

	def authenticate_password(pass)
		password == preprocess_password(pass)
	end

	def password
		@password ||= BCrypt::Password.new(password_bcrypt)
	end

	def password=(password)
		return nil if password.empty? # refuse to set empty passwords

		# BCrypt truncates at 72 characters, and characters >55 contribute
		# less entropy to the key.
		#
		# It also truncates at NULL bytes, which could be used to make an
		# account with what amounts to an empty password.
		#
		# Bypass both issues by making a 64-byte base64 hash of the password first.
		@password = BCrypt::Password.create(preprocess_password(password))
		self.password_bcrypt = @password
	end

	def validate
		super

		validates_presence [:firstname, :lastname]

		validates_unique :email, only_if_modified: true

		# this can no doubt be improved, kept it simple for now
		validates_format /\A[^\s@]+\@[A-Za-z0-9-]+\.[A-Za-z0-9.-]+\Z/, :email

		begin
			password
		rescue BCrypt::Errors::InvalidHash
			errors.add :password, 'invalid password'
		end
	end

	private
	def preprocess_password(password)
		Digest::SHA384.base64digest(password)
	end
end
