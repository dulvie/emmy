class OrganizationsController < ApplicationController
  before_action :load_organization_from_current
  authorize_resource
  before_action :show_breadcrumbs

  # GET /:organization_slug
  def show
    @org_url = organization_path(current_organization.slug, @organization)
    @organization = @organization.decorate
    @document = @organization.logo || @organization.build_logo
    @document_form_url = documents_path(parent_type: 'Organization', parent_id: @organization.id)
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
