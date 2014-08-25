class DashboardController < ApplicationController

  def index
    @breadcrumbs = [['Dashboard']]
    @current_organisation = current_organisation
    authorize! :read, current_user
    @todo_content = File.read(Rails.root + "TODO")
  end

end
