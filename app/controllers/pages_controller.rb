class PagesController < ApplicationController
  skip_authorization_check
  before_filter :authenticate_user!, :except => [:start, :about]

  # only non logged in users should be able to see the start page.
  def start
    if user_signed_in?
      redirect_to dashboard_path
    end
  end

  def about
  end
end
