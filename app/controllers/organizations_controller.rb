class OrganizationsController < ApplicationController
  load_and_authorize_resource
  before_filter :show_breadcrumbs

  # GET /:organization_name
  def show
  end

  # PATCH/PUT /:organization_name
  def update
    if @organization.update(organization_params)
      redirect_to "/#{@organization.slug}", notice: 'Organization was successfully updated.'
    else
      render :show
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def organization_params
    params.require(:organization).permit(Organization.accessible_attributes.to_a)
  end

  def show_breadcrumbs
    @breadcrumbs = [[@organization.name]]
  end
end
