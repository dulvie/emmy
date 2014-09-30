class OrganizationsController < ApplicationController
  load_and_authorize_resource
  before_filter :load_by_pagination, only: :index

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]

  before_filter :only_allow_one, only: [:index, :new, :create]

  # GET /organisations
  def index
    @breadcrumbs = [[t(:organisations)]]
  end

  # GET /organisations/1
  def show
  end

  # GET /organisations/new
  def new
  end

  # POST /organisations
  def create
    @organisation = Organisation.new(organisation_params)

    if @organisation.save
      redirect_to @organisation, notice: 'Organisation was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /organisations/1
  def update
    if @organisation.update(organisation_params)
      redirect_to @organisation, notice: 'Organisation was successfully updated.'
    else
      render :show
    end
  end

  # DELETE /organisations/1
  def destroy
    @organisation.destroy
    redirect_to organisations_url, notice: 'Organisation was successfully destroyed.'
  end

  private

  # Only allow a trusted parameter "white list" through.
  def organisation_params
    params.require(:organisation).permit(Organisation.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:organisations), organisations_path], ["#{t(:new)} #{t(:organisation)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:organisations), organisations_path], [@organisation.name]]
  end


  # before index
  def load_by_pagination
    @organisations = Organisation.accessible_by(current_ability).page(params[:page] || 1)
  end

  def only_allow_one
    if first_org = Organisation.first
      redirect_to first_org
      return false
    end
  end
end
