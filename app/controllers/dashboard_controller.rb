class DashboardController < ApplicationController

  def index
    authorize! :read, current_user
  end

end
