class ImportsController < ApplicationController

  load_and_authorize_resource
 
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:edit, :update]
 
 
  # GET /imports
  # GET /imports.json
  def index
    @breadcrumbs = [[t(:imports)]]
    @imports = @imports.collect{|import| import.decorate}
  end

  # GET /imports/1
  # GET /imports/1.json
  def show
    @breadcrumbs = [['Imports', imports_path], [@import.description]]
    @import = @import.decorate
  end
  
  # GET /imports/new
  def new
  end
  
  # GET /imports/1/edit
  def edit
    if !@import.importing_id.nil?
      @importing = Purchase.find(@import.importing_id)
    end
    if !@import.shipping_id.nil?      
      @shipping = Purchase.find(@import.shipping_id)
    end      
    if !@import.customs_id.nil? 
      @customs = Purchase.find(@import.customs_id)
    end
  end

  # POST /imports
  # POST /imports.json
  def create
    @import = Import.new(import_params)

    respond_to do |format|
      if @import.save
      
        #citems = Import.find(1).costitems        
        #citems.each do |ci|
        #  copy = ci.dup
        #  copy.parent_id = @import.id
        #  copy.save
        #end
                
        format.html { redirect_to edit_import_path(@import), notice: 'import was successfully created.'}
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
        format.html { render action: 'new' }
      end
    end    
  end
  
  def update
    respond_to do |format|
      if @import.update_attributes(import_params)
        format.html { redirect_to edit_import_path(@import), notice: "#{t(:import)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:import)}"
      end
    end
  end
  
  def destroy
    @import.destroy
    respond_to do |format|
      format.html { redirect_to imports_path, notice: "#{t(:import)} #{t(:was_successfully_deleted)}" }
      #format.json { head :no_content }
    end
  end
  
  def new_purchase

    if params[:parent_column] == 'importing'
      @purchase = @import.importing.build
      @purchase.purchase_items.build product_id: @import.product.id
    end
    if params[:parent_column] == 'shipping'
      @purchase = @import.shipping.build
      @purchase.purchase_items.build
    end
    if params[:parent_column] == 'customs'
      @purchase = @import.customs.build
      @purchase.purchase_items.build
    end

    @parent_column = params[:parent_column]   
    @purchase.to_warehouse = @import.to_warehouse
    @purchase.parent_type = 'Import'
    @purchase.parent_id = @import.id

  end

  def create_purchase

    if params[:parent_column] == 'importing'  
      @purchase = @import.importing.build params[:purchase]
      @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
    end

    if params[:parent_column] == 'shipping'
      @purchase = @import.shipping.build params[:purchase]
      @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
    end

    if params[:parent_column] == 'customs'
      @purchase = @import.customs.build params[:purchase]
      @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
    end

    @purchase.save

    if params[:parent_column] == 'importing'  
       @import.importing_id = @purchase.id
    end

    if params[:parent_column] == 'shipping'
       rtn = @import.shipping_id = @purchase.id
    end

    if params[:parent_column] == 'customs'
      rtn = @import.customs_id = @purchase.id
    end

    respond_to do |format|
      if @import.save
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:purchase_item)}"
        format.html { redirect_to edit_import_path(params[:purchase][:parent_id]) }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:import)}"
      end  
    end
  end
  
  def state_change
    @import = Import.find(params[:id])
    if @import.state_change(params[:new_state], params[:state_change_at])
      msg = t(:success)
    else
      msg = t(:fail)
    end
    respond_to do |format|
      format.html { redirect_to edit_import_path(@import), notice: msg}
    end
  end
      
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_params
      params.require(:import).permit(Import.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Imports', imports_path], ["#{t(:new)} #{t(:import)}"]]
    end

    def edit_breadcrumbs
      @breadcrumbs = [['Imports', imports_path], [@import.description]]
    end
end
