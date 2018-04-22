class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  before_action :require_login

private

  def require_login
    unless (current_user or request.env['PATH_INFO'] == signup_path)
      redirect_to login_url
    end
  end
end