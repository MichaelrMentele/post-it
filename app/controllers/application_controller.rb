class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # makes this availbe in all templates
  helper_method :current_user, :logged_in?

  def current_user
    # the ||= is a memorization. Says if it exists don't run the code. 
    # The curent user is available on all controllers
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_user 
    if !logged_in?
      flash[:error] = "You aren't logged in."
      redirect_to root_path
    end
  end

  def require_admin
    # have the logged check first to short circuit the logic
    access_denied unless logged_in? and current_user.admin?
  end

  def access_denied
    flash[:error] = "You can't do that"
    redirect_to root_path
  end
end
