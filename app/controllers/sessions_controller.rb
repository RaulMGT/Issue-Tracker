class SessionsController < ApplicationController
  skip_before_action :require_login
  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase)
    if user && user.password_digest.nil?
      flash.now[:danger] = 'Sign in using Google+'
      render 'new'
    elsif user && user.authenticate(params[:session][:password])
    	log_in(user)
      remember(user)
      redirect_to issues_path
    elsif user.nil?
      flash.now[:danger] = 'Sign in using Google+ or Sign up first'
      render 'new'
  	else
  		flash.now[:danger] = 'Invalid email/password combination'
  		render 'new'
  	end
  end

  def google_create
    user = User.from_omniauth(request.env["omniauth.auth"])
    log_in(user)
    remember(user)
    redirect_to issues_path
  end

  def destroy 
  	log_out
  	redirect_to root_url
  end

end
