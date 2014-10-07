class WarehousesController < ApplicationController
  respond_to :html, :json
  before_filter :load_organization
  load_and_authorize_resource :warehouse, through: :current_organization
  before_filter :show_breadcrumbs, only: [:show, :edit, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :load_contats, only: [:show, :new, :edit, :create, :update]

  # GET /warehouses
  def index
    @breadcrumbs = [['Warehouses']]
    @warehouses = @warehouses.order(:name).page(params[:page]).per(8)
  end

  # GET /warehouses/1
  def show
    render 'edit'
  end

  # GET /warehouses/new
  def new
  end

  # GET /warehouses/1/edit
  def edit
  end

  # POST /warehouses
  def create
    @warehouse = Warehouse.new(warehouse_params)
    @warehouse.organization = current_organization
    if @warehouse.save
      redirect_to warehouses_url, notice: "#{t(:warehouse)} #{t(:was_successfully_created)}"
    else
      render :new
    end
  end

  # PATCH/PUT /warehouses/1
  # PATCH/PUT /warehouses/1.json
  def update
    respond_to do |format|
      if @warehouse.update(warehouse_params)
        format.html { redirect_to warehouses_path, notice: 'Warehouse was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        # format.json { render json: @warehouse.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /warehouses/1
  # DELETE /warehouses/1.json
  def destroy
    @warehouse.destroy
    respond_to do |format|
      format.html { redirect_to warehouses_url, notice: 'Warehouse was successfully deleted.' }
      # format.json { head :no_content }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def warehouse_params
    params.require(:warehouse).permit(Warehouse.accessible_attributes.to_a)
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:warehouses), warehouses_path], [@warehouse.name]]
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:warehouses), warehouses_path], ["#{t(:new)} #{t(:warehouse)}"]]
  end

  def load_contats
    @contacts = @warehouse.contacts
  end
end
