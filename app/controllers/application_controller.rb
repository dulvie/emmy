class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Default is the always ensure the user is signed in.
  before_filter :authenticate_user!

  # Default to always check for authorization (cancan).
  # Except the devise controller (sign in).
  check_authorization :unless => :devise_controller?

end
