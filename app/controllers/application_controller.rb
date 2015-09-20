# coding: utf-8
class ApplicationController < ActionController::Base

	# Make Helper methods available in controllers
  include SessionsHelper

	# Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Handle CSRF Forgery
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    sign_out if signed_in?
    flash[:error] = trl("Verdacht auf CSRF Forgery: Sie wurden abgemeldet.")
    redirect_to root_path
  end

  # Set locale
  before_action :set_locale
 
  def set_locale
    I18n.locale = I18n.default_locale
  end

  # Redirect Back

  def save_referer
    session[:return_to] = request.referer
  end

  def redirect_back_or(destination)
    if session[:return_to]
      redirect_to session.delete(:return_to)
    elsif request.referer
      redirect_to request.referer
    else
      redirect_to destination
    end
  end

  # Translate placeholder
  helper_method :trl
  def trl(string)
    return string
  end

  # Filters

  def require_admin
    unless signed_in? and
        current_user.is_admin
      flash[:alert] = trl("Sie haben nicht die nötigen Rechte, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

  def require_assistant
    unless signed_in? and
        ( current_user.is_admin or
          current_user.is_assistant )
      flash[:alert] = trl("Sie haben nicht die nötigen Rechte, um diese Aktion auszuführen.")
      redirect_back_or root_path
    end
  end

end
