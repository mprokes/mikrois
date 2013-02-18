class ApplicationController < ActionController::Base
  protect_from_forgery
  force_ssl
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authorize
    unless current_user
      flash[:error] = "unauthorized access"
      redirect_to log_in_path
      false
    end
  end

end
