class OrganizationsController < ApplicationController
  load_and_authorize_resource
  before_filter :load_by_pagination, only: :index

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]


  # GET /organizations
  def index
    @breadcrumbs = [[t(:organizations)]]
  end

  # GET /organizations/1
  def show
  end

  # GET /organizations/new
  def new
  end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      redirect_to @organization, notice: 'Organization was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /organizations/1
  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: 'Organization was successfully updated.'
    else
      render :show
    end
  end

  # DELETE /organizations/1
  def destroy
    @organization.destroy
    redirect_to organizations_url, notice: 'Organization was successfully destroyed.'
  end

  private

  # Only allow a trusted parameter "white list" through.
  def organization_params
    params.require(:organization).permit(Organization.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:organizations), organizations_path], ["#{t(:new)} #{t(:organization)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:organizations), organizations_path], [@organization.name]]
  end


  # before index
  def load_by_pagination
    @organizations = Organization.accessible_by(current_ability).page(params[:page] || 1)
  end

end
