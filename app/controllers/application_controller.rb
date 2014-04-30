class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Default is the always ensure the user is signed in.
  before_filter :authenticate_user!

  # Default to always check for authorization (cancan).
  # Except the devise controller (sign in).
  check_authorization :unless => :devise_controller?


  # i18n support
  before_filter :set_locale
  def set_locale
    I18n.locale = locale_from_params || I18n.default_locale
  end

  private
  # only allow certian locales to be passed.
  def locale_from_params
    params[:locale] if (params[:locale] && ['en','se'].include?(params[:locale]))
  end

end
