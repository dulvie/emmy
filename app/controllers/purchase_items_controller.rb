class PurchaseItemsController < ApplicationController
  load_and_authorize_resource :purchase, through: :current_organization
  load_and_authorize_resource :purchase_item, through: :current_organization

  before_action :set_breadcrumbs, only: [:new, :create]

  def new
    init_new
  end

  def create
    @purchase = current_organization.purchases.find(params[:purchase_id])
    @purchase_item = @purchase.purchase_items.build purchase_item_params
    @purchase_item.organization = current_organization
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
    @purchase = current_organization.purchases.find(params[:purchase_id])
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
    params.require(:purchase_item).permit(:batch_id, :item_id, :quantity, :price, :total_amount)
  end

  def set_breadcrumbs
    @breadcrumbs = [[t(:purchases), purchases_path], ["##{@purchase.id}", purchase_path(@purchase)], [t(:add_batch)]]
  end

  def init_new
    if @purchase.to_warehouse.nil?
      @item_selections = current_organization.items.where('stocked = false')
    else
      item_types = ['purchases', 'both']
      @item_selections = current_organization.items.where(item_type: item_types)
    end
    gon.push items: ActiveModel::Serializer::CollectionSerializer.new(@item_selections, each_serializer: ItemSerializer)
  end
end
