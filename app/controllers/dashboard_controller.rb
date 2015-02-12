class DashboardController < ApplicationController
  skip_authorization_check only: [:organization_selector]

  def index
    @breadcrumbs = [['Dashboard']]
  end

  def organization_selector
    params.delete(:organization_slug)
    @organizations = current_user.organization_roles.roles_with_access.map{|role| role.organization}
    session.delete(:accounting_period_id)
  end
end
