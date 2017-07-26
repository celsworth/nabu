# frozen_string_literal: true

class Nabu
  # return a User object for the current session's user
  # currently returns a User.new if no user found
  # so that templates can safely do user.name without raising exceptions
  def user
    @current_user ||= User[session[:user_id]] || User.new
  end
end
