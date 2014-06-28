class SaleItemsController < ApplicationController
  load_and_authorize_resource :sale
  load_and_authorize_resource :sale_item, through: :sale

  before_filter :set_breadcrumbs, only: [:new, :create]

  def new
    @shelves = @sale.warehouse.shelves.includes(:product)
    @sale = @sale.decorate
    gon.push sale: @sale, sale_item: @sale_item, shelves: ActiveModel::ArraySerializer.new(@shelves, each_serializer: ShelfSerializer)
  end

  def create
    @sale = Sale.find(params[:sale_id])
    @sale_item = @sale.sale_items.build sale_item_params
    respond_to do |format|
      if @sale_item.save
        format.html { redirect_to sale_path(@sale), notice: "#{t(:product_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:product)}"
        @shelves = @sale.warehouse.shelves.includes(:product)
        gon.push shelves: ActiveModel::ArraySerializer.new(@shelves, each_serializer: ShelfSerializer)
        format.html {render action: 'new' }
      end
    end
  end

  def destroy
    @sale = Sale.find(params[:sale_id])
    if @sale.can_edit_items?
      item = @sale.sale_items.find(params[:id])
      item.destroy
      msg = "#{t(:sale_item)} #{t(:was_successfully_deleted)}"
    end

    respond_to do |format|
      format.html { redirect_to sale_path(@sale), notice: msg }
      #format.json { head :no_content }
    end
  end

  private

    def sale_item_params
      params.require(:sale_item).permit(SaleItem.accessible_attributes.to_a)
    end

    def set_breadcrumbs
      @breadcrumbs = [[t(:sales), sales_path], ["##{@sale.id}", sale_path(@sale)], [t(:add_product)]]
    end
end
