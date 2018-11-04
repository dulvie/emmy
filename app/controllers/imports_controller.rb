class ImportsController < ApplicationController
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :edit_breadcrumbs, only: [:show, :edit, :update]
  before_action :purchase_breadcrumbs, only: [:new_purchase, :single_purchase]

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
    @imports = Kaminari.paginate_array(imports).page(params[:page])
  end

  # GET /imports/1
  # GET /imports/1.json
  def show
    init_collections
    set_purchases
    @import = @import.decorate
    render 'edit'
  end

  # GET /imports/new
  def new
    init_collections
    @import.our_reference = current_user
  end

  # GET /imports/1/edit
  def edit
    init_collections
    set_purchases
    @import = @import.decorate
  end

  # POST /imports
  # POST /imports.json
  def create
    @import = Import.new(import_params)
    @import.organization = current_organization
    respond_to do |format|
      if @import.save
        format.html { redirect_to edit_import_path(@import), notice: 'import was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
        init_collections
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
      @purchase.description = 'Skeppning'
      @purchase.our_reference = @import.our_reference
      @purchase.purchase_items.build quantity: 1
      @item_selections = current_organization.items.bayable.not_stocked
    end
    if params[:parent_column] == 'customs'
      @purchase = @import.customs.build
      @purchase.description = 'Tull'
      @purchase.our_reference = @import.our_reference
      @purchase.purchase_items.build quantity: 1
      @item_selections = current_organization.items.bayable.not_stocked
    end
    @suppliers = current_organization.suppliers
    @parent_column = params[:parent_column]
    @purchase.to_warehouse = @import.to_warehouse
    @purchase.parent_type = 'Import'
    @purchase.parent_id = @import.id
    gon.push suppliers: ActiveModel::ArraySerializer.new(@suppliers, each_serializer: SupplierSerializer)

  end

  def create_purchase

    if params[:parent_column] == 'shipping'
      @purchase = @import.shipping.build params[:purchase]
      @purchase.organization_id = current_organization.id
      @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
      @purchase.purchase_items.first.organization_id = current_organization.id
      rtn = @purchase.save
    end

    if params[:parent_column] == 'customs'
      @purchase = @import.customs.build params[:purchase]
      @purchase.organization_id = current_organization.id
      @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
      @purchase.purchase_items.first.organization_id = current_organization.id
      rtn = @purchase.save
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
    @import = current_organization.imports.find(params[:id])
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

  def init_collections
    @users = current_organization.users
    @warehouse = current_organization.warehouses
    redirect_to helps_show_message_path(message: "#{I18n.t(:warehouses)} #{I18n.t(:missing)}") if @warehouse.size == 0
  end

  def init_purchase
    if params[:parent_column] == 'shipping'
      item_types = ['purchases', 'both']
      @item_selections = current_organization.items.where(item_type: item_types)
    end
    if params[:parent_column] == 'customs'
      item_types = ['purchases', 'both']
      @item_selections = current_organization.items.where(item_type: item_types)
    end

    @parent_column = params[:parent_column]
    @suppliers = current_organization.suppliers
    gon.push suppliers: ActiveModel::ArraySerializer.new(@suppliers, each_serializer: SupplierSerializer)
  end

  def set_purchases
    unless @import.importing_id.nil?
      if !current_organization.purchases.exists? id: @import.importing_id
        @import.importing_id = nil
        @import.save
      else
        @importing = current_organization.purchases.find(@import.importing_id).decorate
      end
    end
    unless @import.shipping_id.nil?
      if !current_organization.purchases.exists? id: @import.shipping_id
        @import.shipping_id = nil
        @import.save
      else
        @shipping = current_organization.purchases.find(@import.shipping_id).decorate
      end
    end
    unless @import.customs_id.nil?
      if !current_organization.purchases.exists? id: @import.customs_id
        @import.customs_id = nil
        @import.save
      else
        @customs = current_organization.purchases.find(@import.customs_id).decorate
      end
    end
  end
end
