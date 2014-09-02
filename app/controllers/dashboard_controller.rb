class DashboardController < ApplicationController
  def index
    @breadcrumbs = [['Dashboard']]
    @current_organisation = current_organisation
    authorize! :read, current_user
  end
end
