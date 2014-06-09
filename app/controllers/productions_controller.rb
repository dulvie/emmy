class ProductionsController < ApplicationController

  load_and_authorize_resource
 
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:edit, :update]
 
 
  # GET /productions
  # GET /productions.json
  def index
    @breadcrumbs = [[t(:productions)]]
    @productions = @productions.collect{|production| production.decorate}
  end

  # GET /productions/1
  # GET /productions/1.json
  def show
    @breadcrumbs = [['Productions', products_path], [@production.description]]
    @production = @production.decorate
  end
  
  # GET /productions/new
  def new
    @costitems_size = 0
    @materials_size = 0
    @warehouse = Warehouse.find(1);
    @production = Production.new({description: "Ny rostning", warehouse_id: @warehouse.id})
    @production.save
  end
  
  # GET /productions/1/edit
  def edit
    @materials_size = @production.materials_size
    @costitems_size = @production.costitems_size
  end

  # POST /productions
  # POST /productions.json
  def create
    @production = Production.new(production_params)

    respond_to do |format|
      if @production.save
        format.html { redirect_to new_production_path(@production), notice: 'production was successfully created.'}
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
        format.html { render action: 'new' }
      end
    end    
  end

  def update
    respond_to do |format|
      if @production.update_attributes(production_params)
        format.html { redirect_to productions_path(@production), notice: "#{t(:production)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:production)}"
      end
    end
  end
  
  def destroy
    @production.destroy
    respond_to do |format|
      format.html { redirect_to productions_path, notice: "#{t(:production)} #{t(:was_successfully_deleted)}" }
      #format.json { head :no_content }
    end
  end
  
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def production_params
      params.require(:production).permit(Production.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Productions', productions_path], ["#{t(:new)} #{t(:production)}"]]
    end

    def edit_breadcrumbs
      @breadcrumbs = [['Productions', productions_path], [@production.description]]
    end
end
