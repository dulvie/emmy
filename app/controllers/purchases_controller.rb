class PurchasesController < ApplicationController

  load_and_authorize_resource
  before_filter :find_and_authorize_parent
    
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update, :edit]

  def single_purchase
    @purchase = Purchase.new params[:purchase]
    @purchase.user = current_user

    @purchase.purchase_items.build params[:purchase][:purchase_items_attributes][:'0']

       logger.info "param 2: #{params[:purchase][:parent_id]}"
       logger.info "param 3: #{params[:purchase][:parent_type]}"
    respond_to do |format|
      if @purchase.save
        if params[:purchase][:parent_type]=='Import'
          format.html { redirect_to edit_import_path(params[:purchase][:parent_id]), notice: "#{t(:purchase)} #{t(:was_successfully_created)}" }
        else
          format.html { redirect_to edit_production_path(params[:purchase][:parent_id]), notice: "#{t(:purchase)} #{t(:was_successfully_created)}" }
        end
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:purchase_item)}"
        format.html { redirect_to edit_production_path(params[:purchase][:parent_id]) }
      end  
    end
  end

  def new
    if params[:form]=='single_purchase'
      @purchase.purchase_items.build
      @purchase.parent_type = params[:parent_type]
      @purchase.parent_id = params[:parent_id]
      item_types = ['purchases', 'both']
      @item_selections = Item.where(item_type: item_types)
      respond_to do |format|
        format.html { render  "single_form" }
      end  
    end  
  end

  def create  
     @purchase = Purchase.new purchase_params
     @purchase.user = current_user
     respond_to do |format|
      if @purchase.save
        format.html { redirect_to purchase_path(@purchase), notice: "#{t(:purchase)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:purchase)}"
        format.html { render action: :new }
      end      
    end
  end

  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to purchase_path(@purchase), notice: 'supplier was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:purchase)}"
        format.html { render action: 'edit' }
        #format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def index
    @breadcrumbs = [[t(:purchases)]]
    @purchases = @purchases.collect{|purchase| purchase.decorate}
  end

  def show
  end

  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchases_path, notice: "#{t(:purchase)} #{t(:was_successfully_deleted)}" }      
      #format.json { head :no_content }
    end
  end

  def state_change
    @purchase = Purchase.find(params[:id])
          logger.info "param X: #{params[:state_change_at]}"
          logger.info "param X: #{params[:full]}"
    if @purchase.state_change(params[:new_state], params[:state_change_at])    
      msg = t(:success)
    else
      msg = t(:fail)
    end
    if @purchase.is_completed? and @purchase.parent_type == 'Import'
      @parent = Import.find(@purchase.parent_id)
      @parent.check_for_completeness
    end  
    respond_to do |format|
      return_path = purchase_path(@purchase)
      if params[:return_path]
        return_path = params[:return_path]
      end
      format.html { redirect_to return_path, notice: msg}
    end
  end

  private
  
    def find_and_authorize_parent

      # if contact exists, but no parent_type, add from contact.
      unless params.has_key?(:parent_type)
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

    def purchase_item_params
      params.permit(PurchaseItem.accessible_attributes.to_a, purchase_items_attributes: [])
    end
    
    def purchase_params
      params.require(:purchase).permit(Purchase.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [[t(:purchases), purchases_path], ["#{t(:new)} #{t(:purchase)}"]]
    end

    def show_breadcrumbs
      @breadcrumbs = [[t(:purchases), purchases_path], ["##{@purchase.id}"]]
    end

end
