class WarehousesController < ApplicationController

  respond_to :html, :json
  load_and_authorize_resource
  before_filter :show_breadcrumbs, only: [:show, :edit, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :load_contats, only: [:show, :new, :edit, :create, :update]

  # GET /warehouses
  # GET /warehouses.json
  def index
    @breadcrumbs = [['Warehouses']]
    @warehouses = @warehouses.order(:name).page(params[:page]).per(8)
  end

  # GET /warehouses/1
  # GET /warehouses/1.json
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
  # POST /warehouses.json
  def create
    @warehouse = Warehouse.new(warehouse_params)
    @warehouse.organisation = current_organisation
    respond_to do |format|
      if @warehouse.save
        format.html { redirect_to  warehouses_path, notice: 'Warehouse was successfully created.' }
        # format.json { render action: 'show', status: :created, location: @warehouse }
      else
        format.html { render action: 'new' }
        # format.json { render json: @warehouse.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /warehouses/1
  # PATCH/PUT /warehouses/1.json
  def update
    respond_to do |format|
      if @warehouse.update(warehouse_params)
        format.html { redirect_to  warehouses_path, notice: 'Warehouse was successfully updated.' }
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
      format.html { redirect_to warehouses_url, notice: "Warehouse was successfully deleted." }
      # format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def warehouse_params
      params.require(:warehouse).permit(Warehouse.accessible_attributes.to_a)
    end

    def show_breadcrumbs
      @breadcrumbs = [['Warehouses', warehouses_path], [@warehouse.name]]
    end

    def new_breadcrumbs
      @breadcrumbs = [['Warehouses', warehouses_path], ['New warehouse']]
    end

    def load_contats
     @contacts = Contact.where('parent_type = ? and parent_id = ?', 'Warehouse', @warehouse)
    end

end
