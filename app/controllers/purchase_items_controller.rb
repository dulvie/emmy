class PurchaseItemsController < ApplicationController
  load_and_authorize_resource :purchase
  load_and_authorize_resource :purchase_item, through: :purchase

  before_filter :set_breadcrumbs, only: [:new, :create]

  def new
    init_new
  end

  def create
    @purchase = Purchase.find(params[:purchase_id])
    @purchase_item = @purchase.purchase_items.build purchase_item_params
    @purchase_item.organisation = current_organisation
    respond_to do |format|
      if @purchase_item.save
        format.html { redirect_to purchase_path(@purchase), notice: "#{t(:batch_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:batch)}"
        init_new
        format.html { render :new }
      end
    end
  end

  def destroy
    @purchase = Purchase.find(params[:purchase_id])
    if @purchase.can_edit_items?
      item = @purchase.purchase_items.find(params[:id])
      item.destroy
      msg = "#{t(:purchase_item)} #{t(:was_successfully_deleted)}"
    end

    respond_to do |format|
      format.html { redirect_to purchase_path(@purchase), notice: msg }
      # format.json { head :no_content }
    end
  end

  private

  def purchase_item_params
    params.require(:purchase_item).permit(PurchaseItem.accessible_attributes.to_a)
  end

  def set_breadcrumbs
    @breadcrumbs = [[t(:purchases), purchases_path], ["##{@purchase.id}", purchase_path(@purchase)], [t(:add_batch)]]
  end

  def init_new
    if @purchase.to_warehouse.nil?
      @item_selections = Item.where('stocked = false')
    else
      item_types = ['purchases', 'both']
      @item_selections = Item.where(item_type: item_types)
    end
    gon.push items: ActiveModel::ArraySerializer.new(@item_selections, each_serializer: ItemSerializer)
  end
end
