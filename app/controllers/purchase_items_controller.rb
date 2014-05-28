class PurchaseItemsController < ApplicationController
  load_and_authorize_resource :purchase
  load_and_authorize_resource :purchase_item, through: :purchase

  before_filter :set_breadcrumbs, only: [:new, :create]

  def new
    @purchase = @purchase.decorate
    #gon.push sale: @sale, sale_item: @sale_item, shelves: ActiveModel::ArraySerializer.new(@shelves, each_serializer: ShelfSerializer)
  end

  def create
    @purchase = Purchase.find(params[:purchase_id])
    @purchase_item = @purchase.purchase_items.build purchase_item_params
    respond_to do |format|
      if @purchase_item.save
        format.html { redirect_to purchase_path(@purchase), notice: "#{t(:product_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:product)}"
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
      #format.json { head :no_content }
    end
  end

  private

    def purchase_item_params
      params.require(:purchase_item).permit(PurchaseItem.accessible_attributes.to_a)
    end

    def set_breadcrumbs
      @breadcrumbs = [[t(:purchases), purchases_path], ["##{@purchase.id}", purchase_path(@purchase)], [t(:add_product)]]
    end
end
