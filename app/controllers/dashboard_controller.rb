class DashboardController < ApplicationController

  def index
    @current_organisation = current_organisation
    authorize! :read, current_user
    @todo_content = File.read(Rails.root + "TODO")
    @breadcrumbs = [['Dashboard']]
  end

end
