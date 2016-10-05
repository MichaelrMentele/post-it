class SessionsController < ApplicationController
  def new

  end

  def create
    user = User.where(username: params[:username]).first

    if user && user.authenticate(params[:password])
      if user.two_factor_auth?
        session[:two_factor] = true
        # gen a pin
        user.generate_pin!
        user.send_pin_to_twilio
        redirect_to pin_path
      else
        log_user_in(user)
      end
    else
      flash[:error] = "User information incorrect."
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You've logged out."
    redirect_to root_path
  end

  # both get and post point to same endpoint
  def pin
    access_denied if session[:two_factor].nil?

    if request.post?
      user = User.find_by pin: params[:pin]
      if user
        log_user_in(user)
        session[:two_factor] = nil
        user.remove_pin!
      else
        flash[:error] = "Incorrect pin."
        redirect_to pin_path
      end
    end
  end

  private

  def log_user_in(user)
    session[:user_id] = user.id
    flash[:notice] = "Welcome, you've logged in"
    redirect_to root_path
  end

end