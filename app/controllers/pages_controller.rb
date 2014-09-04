class PagesController < ApplicationController
  # Everybody can se pages.
  # Skip the cancan thingie and the authenticate_user! filter
  skip_authorization_check
  before_filter :authenticate_user!, except: [:start, :about, :formats]

  # Only non logged in users should be able to see the start page.
  def start
    @breadcrumbs = [['/']]
    redirect_to dashboard_path if user_signed_in?
  end

  def about
    @breadcrumbs = [[t(:about)]]
  end

  def formats
  end
end
