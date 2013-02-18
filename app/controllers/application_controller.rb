class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user
  before_filter :set_audit_user

  def set_locale
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    I18n.locale = extract_locale_from_accept_language_header
    logger.debug "* Locale set to '#{I18n.locale}'"
  end

  private

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def anonymous_user
    User.find_by_email('anonymous@mikrois.cz')
  end

  def authorize
    unless current_user
      flash[:error] = "unauthorized access"
      redirect_to log_in_path
      false
    end
  end

  def set_audit_user
    Auditor::User.current_user = current_user
    Auditor::User.current_user ||= User.find_by_email('anonymous@mikrois.cz')
  end

end
