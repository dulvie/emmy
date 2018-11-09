class PurchasesController < ApplicationController
  load_and_authorize_resource through: :current_organization
  before_action :find_and_authorize_parent

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:show, :update, :edit]

  def index
    @breadcrumbs = [[t(:purchases)]]
    if params[:state] == 'meta_complete'
      purchases = @purchases.where('state = ?', 'meta_complete').collect { |purchase| purchase.decorate }
    elsif params[:state] == 'prepared'
      purchases = @purchases.where('state = ?', 'prepared').collect { |purchase| purchase.decorate }
    else
      purchases = @purchases.order('ordered_at DESC').collect { |purchase| purchase.decorate }
    end
    @purchases = Kaminari.paginate_array(purchases).page(params[:page])
  end

  def show
    init_collections
  end

  def new
    if params[:form] == 'single_purchase'
      @purchase.purchase_items.build quantity: 1
      @purchase.parent_type = params[:parent_type]
      @purchase.parent_id = params[:parent_id]
      @purchase.description = 'Rostning'
      @purchase.our_reference = current_user
      init_new_work
      init_collections
      gon.push suppliers: ActiveModel::ArraySerializer.new(@suppliers, each_serializer: SupplierSerializer)
      respond_to do |format|
        format.html { render 'single_form' }
      end
    end
    @purchase.our_reference = current_user
    init_collections
    gon.push suppliers: ActiveModel::ArraySerializer.new(@suppliers, each_serializer: SupplierSerializer)
  end

  def create
    @purchase = Purchase.new purchase_params
    @purchase.user = current_user
    @purchase.organization = current_organization
    respond_to do |format|
      if @purchase.save
        format.html { redirect_to purchase_path(@purchase), notice: "#{t(:purchase)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:purchase)}"
        init_collections
        gon.push suppliers: ActiveModel::ArraySerializer.new(@suppliers, each_serializer: SupplierSerializer)
        format.html { render action: :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to purchase_path(@purchase), notice: 'supplier was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:purchase)}"
        init_collections
        format.html { render action: 'show' }
      end
    end
  end

  def edit
  end

  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: "#{t(:purchase)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    supplier_reference = ''
    if params[:purchase]
      supplier_reference = params[:purchase][:supplier_reference] || ''
      Rails.logger.info "->#{supplier_reference}"
    end  
    @purchase = current_organization.purchases.find(params[:id])
    if @purchase.state_change(params[:event], params[:state_change_at], supplier_reference)
      msg = t(:success)
    else
      msg = t(:fail)
    end
    if @purchase.completed? && @purchase.parent_type == 'Import'
      @parent = current_organization.imports.find(@purchase.parent_id)
      @parent.check_for_completeness
    end
    respond_to do |format|
      return_path = purchase_path(@purchase)
      return_path = params[:return_path] if params[:return_path]
      format.html { redirect_to return_path, notice: msg }
    end
  end

  def single_purchase
    @purchase = Purchase.new params[:purchase]
    @purchase.user = current_user
    @purchase.organization = current_organization
    @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']
    @purchase.purchase_items.first.organization = current_organization
    respond_to do |format|
      if @purchase.save
        if params[:purchase][:parent_type] == 'Import'
          format.html { redirect_to edit_import_path(params[:purchase][:parent_id]), notice: "#{t(:purchase)} #{t(:was_successfully_created)}" }
        else
          format.html { redirect_to edit_production_path(params[:purchase][:parent_id]), notice: "#{t(:purchase)} #{t(:was_successfully_created)}" }
        end
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:purchase_item)}"
        init_new
        init_collections
        gon.push suppliers: ActiveModel::ArraySerializer.new(@suppliers, each_serializer: SupplierSerializer)
        format.html { render 'single_form' }
      end
    end
  end

  private

  def find_and_authorize_parent
    # if contact exists, but no parent_type, add from contact.
    unless params.key?(:parent_type)
      params[:parent_type] = 'Purchase'
      params[:parent_id] = 0
    end

    unless Purchase::VALID_PARENT_TYPES.include? params[:parent_type]
      logger.info "SECURITY: invalid parent_type(#{params[:parent_type]}) sent to #{request.original_url} "
      redirect_to '/'
      return false
    end

    unless params[:parent_type] == 'Purchase'
      parent_class = params[:parent_type].constantize
      @parent = parent_class.find(params[:parent_id])
      authorize! :manage, @parent
    end
  end

  def init_new
    item_types = ['purchases', 'both']
    @item_selections = current_organization.items.where(item_type: item_types)
  end

  def init_new_work
    item_types = ['purchases', 'both']
    @item_selections = current_organization.items.where(item_type: item_types, stocked: false)
  end

  def init_collections
    @suppliers = current_organization.suppliers
    @warehouses = current_organization.warehouses
    @users = current_organization.users

    message = "#{I18n.t(:suppliers)} #{I18n.t(:missing)}" if @suppliers.size == 0
    message = "#{I18n.t(:warehouses)} #{I18n.t(:missing)}" if @warehouses.size == 0
    redirect_to helps_show_message_path(message:message) if @suppliers.size == 0 || @warehouses.size == 0
   end

  def purchase_item_params
    params.permit([:batch_id, :item_id, :quantity, :price, :total_amount], purchase_items_attributes: [])
  end

  def purchase_params
    params.require(:purchase).permit(:description, :supplier_id, :contact_name, :contact_email,
                                     :our_reference_id, :to_warehouse_id, :ordered_at, :parent_type,
                                     :parent_id)
  end

  def new_breadcrumbs
    if params[:form] == 'single_purchase'
      obj_id = params[:parent_id]
      @breadcrumbs = [[t(:productions), productions_path], [Production.find(obj_id).description, production_path(obj_id)], ["#{t(:new)} #{t(:purchase)}"]]
    else
      @breadcrumbs = [[t(:purchases), purchases_path], ["#{t(:new)} #{t(:purchase)}"]]
    end
    @purchase.parent_type = params[:parent_type]
    @purchase.parent_id = params[:parent_id]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:purchases), purchases_path], ["##{@purchase.id}"]]
  end
end
