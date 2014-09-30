class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Default is the always ensure the user is signed in.
  before_filter :authenticate_user!

  # Default to always check for authorization (cancan),
  # except the devise controller (sign in).
  check_authorization unless: :devise_controller?

  # i18n support using param from the url.
  before_filter :set_locale
  def set_locale
    I18n.locale = locale_from_params || I18n.default_locale
  end

  # Add the locale to all the links.
  def default_url_options(options = {})
    options.merge(locale: I18n.locale)
  end

  def current_organization
    halt(403) unless current_user
    @current_organization ||= Organization.find_by_name(params[:organization_name])
    authorize! :read, @current_organization
  end

  private

  # only allow certian locales to be passed.
  def locale_from_params
    params[:locale] if (params[:locale] && ['en', 'se'].include?(params[:locale]))
  end
end
