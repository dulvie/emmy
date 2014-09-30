class DashboardController < ApplicationController
  before_filter :ensure_default_organization

  def index
    @breadcrumbs = [['Dashboard']]
    @organization = current_organization
  end

  def ensure_default_organization
    unless current_user.default_organization
      redirect_to(new_organization_path)
    end
  end
end
