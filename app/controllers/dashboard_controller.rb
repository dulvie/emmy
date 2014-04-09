class DashboardController < ApplicationController

  def index
    authorize! :read, current_user
    @todo_content = File.read(Rails.root + "TODO")
  end

end
