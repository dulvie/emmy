class SaleItemsController < ApplicationController
  load_and_authorize_resource

  def create
    @sale = Sale.find(params[:sale_id])
    @sale_item = @sale.sale_items.build sale_item_params
    if @sale_item.save
      msg_prms = {notice: "#{t(:product_added)}"}
    else
      msg_prms = {notice: "#{t(:failed_to_add_product)}"}
    end
    respond_to do |format|
      format.html { redirect_to edit_sale_path(@sale), msg_prms }
    end
  end

  private

    def sale_item_params
      params.require(:sale_item).permit(SaleItem.accessible_attributes.to_a)
    end
end
