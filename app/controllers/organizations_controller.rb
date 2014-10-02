class OrganizationsController < ApplicationController
  before_filter :load_organization_from_current
  authorize_resource
  before_filter :show_breadcrumbs

  # GET /:organization_slug
  def show
  end

  # PATCH/PUT /:organization_slug
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

  def load_organization_from_current
    if params[:organization_slug]
      @organization = current_organization
    end
  end
end
