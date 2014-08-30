class ImportsController < ApplicationController
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:show, :edit, :update]
  before_filter :purchase_breadcrumbs, only: [:new_purchase, :single_purchase]

  # GET /imports
  # GET /imports.json
  def index
    @breadcrumbs = [[t(:imports)]]
    if params[:state] == 'not_started'
      imports = @imports.where('state = ?', 'not_started').collect { |import| import.decorate }
    elsif params[:state] == 'started'
      imports = @imports.where('state = ?', 'started').collect { |import| import.decorate }
    else
      imports = @imports.order(:started_at).collect { |import| import.decorate }
    end
    @imports = Kaminari.paginate_array(imports).page(params[:page]).per(8)
  end

  # GET /imports/1
  # GET /imports/1.json
  def show
    set_purchases
    render 'edit'
  end

  # GET /imports/new
  def new
    @import.our_reference = current_user
  end

  # GET /imports/1/edit
  def edit
    set_purchases
  end

  # POST /imports
  # POST /imports.json
  def create
    @import = Import.new(import_params)
    @import.organisation = current_organisation
    respond_to do |format|
      if @import.save
        format.html { redirect_to edit_import_path(@import), notice: 'import was successfully created.' }
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
      # format.json { head :no_content }
    end
  end

  def new_purchase

    if params[:parent_column] == 'shipping'
      @purchase = @import.shipping.build
      @purchase.description = 'Shipping'
      @purchase.our_reference = @import.our_reference
      @purchase.purchase_items.build quantity: 1
       item_types = ['purchases', 'both']
      @item_selections = Item.where(item_type: item_types)
    end
    if params[:parent_column] == 'customs'
      @purchase = @import.customs.build
      @purchase.description = 'Customs'
      @purchase.our_reference = @import.our_reference
      @purchase.purchase_items.build quantity: 1
       item_types = ['purchases', 'both']
      @item_selections = Item.where(item_type: item_types)
    end

    @parent_column = params[:parent_column]
    @purchase.to_warehouse = @import.to_warehouse
    @purchase.parent_type = 'Import'
    @purchase.parent_id = @import.id
    gon.push suppliers: ActiveModel::ArraySerializer.new(Supplier.all, each_serializer: SupplierSerializer)

  end

  def create_purchase

    if params[:parent_column] == 'importing'
      @purchase = @import.importing.build params[:purchase]
      @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
      rtn = @purchase.save
    end

    if params[:parent_column] == 'shipping'
      @purchase = @import.shipping.build params[:purchase]
      @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
      rtn = @purchase.save
    end

    if params[:parent_column] == 'customs'
      @purchase = @import.customs.build params[:purchase]
      @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
      rtn = @purchase.save
    end

    if params[:parent_column] == 'importing'
      @import.importing_id = @purchase.id
    end

    if params[:parent_column] == 'shipping'
      @import.shipping_id = @purchase.id
    end

    if params[:parent_column] == 'customs'
      @import.customs_id = @purchase.id
    end

    respond_to do |format|
      if rtn && @import.save
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:purchase_item)}"
        format.html { redirect_to edit_import_path(params[:purchase][:parent_id]) }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:import)}"
        init_purchase
        format.html { render :new_purchase }
      end
    end
  end

  def state_change
    @import = Import.find(params[:id])
    if @import.state_change(params[:event], params[:state_change_at])
      msg = t(:success)
    else
      msg = t(:fail)
    end
    respond_to do |format|
      format.html { redirect_to edit_import_path(@import), notice: msg }
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

  def purchase_breadcrumbs
    @breadcrumbs = [['Imports', imports_path], [@import.description, import_path(@import)]]

    case params[:parent_column]
    when 'customs'
      @breadcrumbs << ["#{t(:new)} #{t(:customs)}"]
    when 'shipping'
      @breadcrumbs << ["#{t(:new)} #{t(:shipping)}"]
    else
      @breadcrumbs << ["#{t(:new)} #{t(:purchase)}"]
    end
  end

  def init_purchase
    if params[:parent_column] == 'shipping'
      item_types = ['purchases', 'both']
      @item_selections = Item.where(item_type: item_types)
    end
    if params[:parent_column] == 'customs'
      item_types = ['purchases', 'both']
      @item_selections = Item.where(item_type: item_types)
    end

    @parent_column = params[:parent_column]
    gon.push suppliers: ActiveModel::ArraySerializer.new(Supplier.all, each_serializer: SupplierSerializer)
  end

  def set_purchases
    unless @import.importing_id.nil?
      if !Purchase.exists? id: @import.importing_id
        @import.importing_id = nil
        @import.save
      else
        @importing = Purchase.find(@import.importing_id)
      end
    end
    unless @import.shipping_id.nil?
      if !Purchase.exists? id: @import.shipping_id
        @import.shipping_id = nil
        @import.save
      else
        @shipping = Purchase.find(@import.shipping_id)
      end
    end
    unless @import.customs_id.nil?
      if !Purchase.exists? id: @import.customs_id
        @import.customs_id = nil
        @import.save
      else
        @customs = Purchase.find(@import.customs_id)
      end
    end
  end
end
